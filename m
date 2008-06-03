From: "Ramachandra K" <ramachandra.kuchimanchi@qlogic.com>
Subject: Re: [ofa-general] Re: [PATCH v3 08/13] QLogic VNIC: sysfs interface implementation for the driver
Date: Tue, 3 Jun 2008 17:54:19 +0530
Message-ID: <71d336490806030524r6aa6fed6rdb166efb11385969@mail.gmail.com>
References: <20080529095126.9943.84692.stgit@localhost.localdomain>
	 <20080529095754.9943.27936.stgit@localhost.localdomain>
	 <20080529103003.010c4a08@extreme> <20080529174805.GA10903@kroah.com>
	 <ada7id7685e.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Greg KH" <greg@kroah.com>, amar.mudrankit@qlogic.com,
	netdev@vger.kernel.org, general@lists.openfabrics.org,
	"Stephen Hemminger" <shemminger@vyatta.com>,
	poornima.kamath@qlogic.com
To: "Roland Dreier" <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:12844 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752107AbYFCMYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:24:20 -0400
Received: by yw-out-2324.google.com with SMTP id 9so783671ywe.1
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2008 05:24:19 -0700 (PDT)
In-Reply-To: <ada7id7685e.fsf@cisco.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roland,

On Sun, Jun 1, 2008 at 11:16 AM, Roland Dreier <rdreier@cisco.com> wrote:
>  > And yes, multiple values per sysfs file are not allowed, sorry, please
>  > change this.  If you need to configure your device through an interface
>  > like this, consider using configfs instead, that is what it is there
>  > for.
>
> Makes sense... I know that the SRP initiator uses the method of multiple
> 'token=<value>' entries passed into sysfs, but the excuse is that SRP
> was merged before configfs.

OK. We will investigate moving the qlgc_vnic driver to configfs. What is the
deadline by which we need to be ready for a merge to 2.6.27 ?

Regards,
Ram
