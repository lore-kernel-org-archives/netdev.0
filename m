From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: [2.6.19 PATCH 1/7] ehea: interface to network stack
Date: Mon, 21 Aug 2006 14:23:53 +0200
Message-ID: <200608211423.54250.ossthema@de.ibm.com>
References: <200608181329.02042.ossthema@de.ibm.com> <20060818144429.GF5201@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <osstklei@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([195.212.29.135]:2241 "EHLO
	mtagate2.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1030446AbWHUNDw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 09:03:52 -0400
To: Alexey Dobriyan <adobriyan@gmail.com>
In-Reply-To: <20060818144429.GF5201@martell.zuzino.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

On Friday 18 August 2006 16:44, Alexey Dobriyan wrote:
> > +static int ehea_init_port_res(struct ehea_port *port, struct ehea_port_res *pr,
> > +			      struct port_res_cfg *pr_cfg, int queue_token)
> > +{
> > +	int ret = -EINVAL;
> > +	int max_rq_entries = 0;
> > +	enum ehea_eq_type eq_type = EHEA_EQ;
> > +	struct ehea_qp_init_attr *init_attr = NULL;
> > +	struct ehea_adapter *adapter = port->adapter;
> > +
> > +	memset(pr, 0, sizeof(struct ehea_port_res));
> > +
> > +	pr->skb_arr_rq3 = NULL;
> > +	pr->skb_arr_rq2 = NULL;
> > +	pr->skb_arr_rq1 = NULL;
> > +	pr->skb_arr_sq = NULL;
> > +	pr->qp = NULL;
> > +	pr->send_cq = NULL;
> > +	pr->recv_cq = NULL;
> > +	pr->send_eq = NULL;
> > +	pr->recv_eq = NULL;
> 
> After memset unneeded. ;-)
> 

Is it valid (common in the kernel environment) to treat NULL as 0 after a memset
and thus to forget about initialization?

Thanks,
Jan-Bernd
