From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 net-next 5/8] qlcnic: Cleanup of structure
 qlcnic_hardware_context
Date: Mon, 24 Jun 2013 11:19:22 -0700
Message-ID: <1372097962.1245.14.camel@joe-AO722>
References: <1371888727-16422-1-git-send-email-jitendra.kalsaria@qlogic.com>
	 <1371888727-16422-6-git-send-email-jitendra.kalsaria@qlogic.com>
	 <1371898428.3137.5.camel@joe-AO722>
	 <446476BDCB53C441A1847D74CB603378DA72D5@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Pratik Pujar <pratik.pujar@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:36009 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752586Ab3FXSTX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jun 2013 14:19:23 -0400
In-Reply-To: <446476BDCB53C441A1847D74CB603378DA72D5@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-24 at 18:17 +0000, Pratik Pujar wrote:
> >-----Original Message-----
> >From: Joe Perches [mailto:joe@perches.com]
> >Sent: 22 June 2013 16:24
> >To: Jitendra Kalsaria
> >Cc: David Miller; netdev; Sony Chacko; Shahed Shaikh; Dept-NX Linux NIC
> >Driver; Pratik Pujar
> >Subject: Re: [PATCH v2 net-next 5/8] qlcnic: Cleanup of structure
> >qlcnic_hardware_context
> >
> >On Sat, 2013-06-22 at 04:12 -0400, Jitendra Kalsaria wrote:
> >> From: Pratik Pujar <pratik.pujar@qlogic.com>
> >
> >This isn't really a cleanup.
> >It's allowing more capabilities.
> 
> The driver was dealing with extra capabilities but separate variables
> were used for these. Now instead of using separate variables, clubbed
> in a single array. 

What was 2 is now 3 no?

> >> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
> >> b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
> >[]
> >> @@ -449,7 +449,7 @@ struct qlcnic_hardware_context {
> >>  	u16 max_pci_func;
> >>
> >>  	u32 capabilities;
> >> -	u32 capabilities2;
> >> +	u32 extra_capability[3];
