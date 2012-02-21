From: <Ajit.Khaparde@Emulex.Com>
Subject: RE: [net-next RFC v2 0/2] Patch series to add VF privilege support
Date: Tue, 21 Feb 2012 14:05:35 -0800
Message-ID: <49395329523DD64492581B505F80C86D5BDCF681FF@EXMAIL.ad.emulex.com>
References: <20120214192623.GA14138@akhaparde-VBox>
 <20120214.143746.956650123702374199.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:39999 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752998Ab2BUWLU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 17:11:20 -0500
In-Reply-To: <20120214.143746.956650123702374199.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, February 14, 2012 1:38 PM
> To: Khaparde, Ajit
> Cc: netdev@vger.kernel.org
> Subject: Re: [net-next RFC v2 0/2] Patch series to add VF privilege support
> 
> From: Ajit Khaparde <ajit.khaparde@Emulex.Com>
> Date: Tue, 14 Feb 2012 13:26:23 -0600
> 
> > Adds support to configure privileges for VFs.
> 
> Thanks for not explaining what the hell VF privileges are nor
> why we're even interested in supporting it.

Sorry about that.

Privilege is a bit mask that defines what operations the VF is permitted.
The capabilities of the CNA can be categorized under various Privileges.
When SRIOV is enabled, while a PF will have unrestricted access to all the capabilities of the CNA,
the scope of access of a VF can be limited to the subset of the capabilities that a PF can access.
And the capabilities of a VF can be controlled by these privileges.

Sorry for the delay. I was out of action for a while.

Thanks
-Ajt
