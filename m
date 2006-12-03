From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH  v2 03/13] Provider Methods and Data Structures
Date: Sun, 03 Dec 2006 13:07:18 +0100
Message-ID: <1165147639.3233.211.camel@laptopd505.fenrus.org>
References: <20061202224917.27014.15424.stgit@dell3.ogc.int>
	 <20061202224947.27014.59189.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, netdev@vger.kernel.org,
	openib-general@openib.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:23685 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1757055AbWLCMHZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 07:07:25 -0500
To: Steve Wise <swise@opengridcomputing.com>
In-Reply-To: <20061202224947.27014.59189.stgit@dell3.ogc.int>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-12-02 at 16:49 -0600, Steve Wise wrote:

> +
> +static struct ib_ah *iwch_ah_create(struct ib_pd *pd,
> +				    struct ib_ah_attr *ah_attr)
> +{
> +	return ERR_PTR(-ENOSYS);
> +}


-ENOSYS is just about ALWAYS a bug in that it's guaranteed to be the
wrong error code ;)


