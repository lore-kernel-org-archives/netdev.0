From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: Re: [net-next-2.6 PATCH 1/2] be2net: Add support for next
	generation of BladeEngine device
Date: Thu, 15 Oct 2009 09:19:01 +0530
Message-ID: <20091015034858.GB10799@serverengines.com>
References: <20091014122358.GA11905@serverengines.com> <20091014.152402.92489105.davem@davemloft.net> <20091014.163345.28372235.davem@davemloft.net>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.26]:46783 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753464AbZJODuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 23:50:20 -0400
Received: by qw-out-2122.google.com with SMTP id 9so154590qwb.37
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2009 20:49:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20091014.163345.28372235.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/10/09 16:33 -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 14 Oct 2009 15:24:02 -0700 (PDT)
> 
> > From: Ajit Khaparde <ajitk@serverengines.com>
> > Date: Wed, 14 Oct 2009 17:54:09 +0530
> > 
> >> Add new PCI ids to support next generation of BladeEnigne device.
> >> 
> >> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
> > 
> > Applied.
> 
> I have to revert your changes, how did this even build for you?
> 
> In file included from drivers/net/benet/be_cmds.c:18:
> drivers/net/benet/be.h:45:1: warning: "BE_DEVICE_ID1" redefined
> drivers/net/benet/be.h:44:1: warning: this is the location of the previous definition
> drivers/net/benet/be.h:48:1: warning: "OC_DEVICE_ID2" redefined
> drivers/net/benet/be.h:47:1: warning: this is the location of the previous definition
> 
> Well, obviously, since in your patch:
> 
>  #define BE_VENDOR_ID 		0x19a2
>  #define BE_DEVICE_ID1		0x211
> +#define BE_DEVICE_ID1		0x221
>  #define OC_DEVICE_ID1		0x700
>  #define OC_DEVICE_ID2		0x701
> +#define OC_DEVICE_ID2		0x710
> 
> drivers/net/benet/be.h:56: error: 'OC_DEVICE_ID3' undeclared (first use in this function)
> drivers/net/benet/be.h:58: error: 'BE_DEVICE_ID2' undeclared (first use in this function)
> 
> The mistake is obvious, and you provably didn't even compile check
> these changes.
> 
> How can I possibly take your patches seriously when it is clear how
> incredibly careless you are being here?

Sorry Dave. My bad. Now I realize what happened.
After I compiled and tried my changes, the setup got rebooted and I picked
the files from a wrong sandbox. And these wrong files got committed to git.
I will be careful next time.
