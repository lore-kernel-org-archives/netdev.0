From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Subject: Re: [2.6.19 PATCH 3/7] ehea: queue management
Date: Fri, 18 Aug 2006 16:40:34 +0200
Message-ID: <20060818144034.GD6393@wohnheim.fh-wedel.de>
References: <200608181331.19501.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <osstklei@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wohnheim.fh-wedel.de ([213.39.233.138]:56215 "EHLO
	wohnheim.fh-wedel.de") by vger.kernel.org with ESMTP
	id S1030431AbWHROki (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 10:40:38 -0400
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Content-Disposition: inline
In-Reply-To: <200608181331.19501.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 18 August 2006 13:31:19 +0200, Jan-Bernd Themann wrote:
>
> +	if (queue->current_q_offset > queue->queue_length) {
> +		queue->current_q_offset -=3D queue->pagesize;
> +		retvalue =3D NULL;
> +	}
> +	else if ((((u64) retvalue) & (EHEA_PAGESIZE-1)) !=3D 0) {

	} else if (((u64) retvalue) & (EHEA_PAGESIZE-1)) {

> +		if (hret < H_SUCCESS) {

Do you have a reason to keep H_SUCCESS?

> +   	if(qp_attr->rq_count > 1)
> +		hw_queue_dtor(&qp->hw_rqueue2);
> +   	if(qp_attr->rq_count > 2)

Small amount of whitespace damage.

J=F6rn

--=20
Write programs that do one thing and do it well. Write programs to work
together. Write programs to handle text streams, because that is a
universal interface.
-- Doug MacIlroy
