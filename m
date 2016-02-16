From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH net-next V2 5/6] e1000: call
 ndo_stop()	instead of dev_close() when running offline selftest
Date: Tue, 16 Feb 2016 20:02:09 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81E8B086@ORSMSX101.amr.corp.intel.com>
References: <1454487652-1545-1-git-send-email-sassmann@kpanic.de>
 <1454487652-1545-6-git-send-email-sassmann@kpanic.de>
 <309B89C4C689E141A5FF6A0C5FB2118B81E89BE2@ORSMSX101.amr.corp.intel.com>,<D922F8B9-0F84-45C5-8BD6-6D57ABFAF01D@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>,
	Stefan Assmann <sassmann@kpanic.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12823 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751284AbcBPUCL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 15:02:11 -0500
In-Reply-To: <D922F8B9-0F84-45C5-8BD6-6D57ABFAF01D@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Rustad, Mark D
> Sent: Tuesday, February 16, 2016 9:23 AM
> To: Stefan Assmann
> Cc: intel-wired-lan@lists.osuosl.org; netdev@vger.kernel.org; davem@davemloft.net; Brown, Aaron F
> Subject: Re: [Intel-wired-lan] [PATCH net-next V2 5/6] e1000: call ndo_stop()   instead of dev_close() when running offline selftest
> 
> > Checkpatch warns that externs should be avoided in .c files, but they
> > pre-existed and are just being flagged due to the name changing, so...
> >
> > Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> 
> Actually, it is the forward declarations in the .c that should be deleted.
> The prototypes should only exist in the .h file.

Thanks Mark,  I completely missed that the patch added it to both files, too busy reviving older hardware to extend to run the diags against a larger set of parts I guess :")
