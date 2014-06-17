From: KY Srinivasan <kys@microsoft.com>
Subject: RE: hyperv: fix apparent cut-n-paste error in send path teardown
Date: Tue, 17 Jun 2014 10:13:25 +0000
Message-ID: <1c8d2b180c6c45e09f41282904ebdb1c@BY2PR03MB299.namprd03.prod.outlook.com>
References: <20140616205902.GA7331@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Dave Jones <davej@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1lp0145.outbound.protection.outlook.com ([207.46.163.145]:30157
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751994AbaFQK3C convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 06:29:02 -0400
In-Reply-To: <20140616205902.GA7331@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Dave Jones [mailto:davej@redhat.com]
> Sent: Monday, June 16, 2014 1:59 PM
> To: netdev@vger.kernel.org
> Cc: KY Srinivasan
> Subject: hyperv: fix apparent cut-n-paste error in send path teardown
> 
> c25aaf814a63: "hyperv: Enable sendbuf mechanism on the send path" added
> some teardown code that looks like it was copied from the recieve path
> above, but missed a variable name replacement.

Thank you.

K. Y
> 
> Signed-off-by: Dave Jones <davej@redhat.com>
> 
> diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c index
> c041f63a6d30..4ed38eaecea8 100644
> --- a/drivers/net/hyperv/netvsc.c
> +++ b/drivers/net/hyperv/netvsc.c
> @@ -189,7 +189,7 @@ static int netvsc_destroy_buf(struct netvsc_device
> *net_device)
>  				   "unable to teardown send buffer's
> gpadl\n");
>  			return ret;
>  		}
> -		net_device->recv_buf_gpadl_handle = 0;
> +		net_device->send_buf_gpadl_handle = 0;
>  	}
>  	if (net_device->send_buf) {
>  		/* Free up the receive buffer */
