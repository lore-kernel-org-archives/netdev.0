From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: Poorer networking performance in later kernels?
Date: Tue, 19 Apr 2016 17:58:03 +0200
Message-ID: <5716558B.2080103@hartkopp.net>
References: <SN1PR0301MB19987565B71A4688593A2CDBD6680@SN1PR0301MB1998.namprd03.prod.outlook.com>
 <SN1PR0301MB19983946D7A38001E4B54D20D6680@SN1PR0301MB1998.namprd03.prod.outlook.com>
 <57116D21.8000807@hpe.com>
 <BY2PR0301MB1990F3095CFA07EBBE600F9DD66B0@BY2PR0301MB1990.namprd03.prod.outlook.com>
 <57152600.7000801@hpe.com>
 <SN1PR0301MB19983F545852731CD1410DB9D66C0@SN1PR0301MB1998.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: "Butler, Peter" <pbutler@sonusnet.com>,
	Rick Jones <rick.jones2@hpe.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.216]:19725 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932796AbcDSP63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 11:58:29 -0400
In-Reply-To: <SN1PR0301MB19983F545852731CD1410DB9D66C0@SN1PR0301MB1998.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/19/2016 04:54 PM, Butler, Peter wrote:

>
> I think the issue is resolved.  I had to recompile my 4.4.0 kernel with a few options pertaining to the Intel NIC which somehow (?) got left out or otherwise clobbered when I ported my 3.4.2 .config to the 4.4.0 kernel source tree.  With those changes now in I see essentially identical performance with the two kernels.  Sorry for any confusion and/or waste of time here.  My bad.
>

Can you please send the relevant changes in the config that caused the 
discussed issue?

Just in the case other people do a similar kernel upgrade from 3.x to a 
recent kernel and the current defaults lead to this non-optimal result.

Thanks,
Oliver
