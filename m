From: "Ramachandra K" <ramachandra.kuchimanchi@qlogic.com>
Subject: Re: [ofa-general] Re: [PATCH v3 01/13] QLogic VNIC: Driver - netdev implementation
Date: Tue, 3 Jun 2008 17:44:23 +0530
Message-ID: <71d336490806030514k580418e3n23790eb793e99381@mail.gmail.com>
References: <20080529095126.9943.84692.stgit@localhost.localdomain>
	 <20080529095423.9943.77528.stgit@localhost.localdomain>
	 <20080529102752.584147ee@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com,
	amar.mudrankit@qlogic.com, general@lists.openfabrics.org,
	poornima.kamath@qlogic.com
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.29]:53418 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755069AbYFCMO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:14:28 -0400
Received: by yw-out-2324.google.com with SMTP id 9so780677ywe.1
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2008 05:14:23 -0700 (PDT)
In-Reply-To: <20080529102752.584147ee@extreme>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 29, 2008 at 10:57 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Thu, 29 May 2008 15:24:23 +0530
> Ramachandra K <ramachandra.kuchimanchi@qlogic.com> wrote:

<snip>
>
>> +module_param(vnic_debug, uint, 0444);
>> +MODULE_PARM_DESC(vnic_debug, "Enable debug tracing if > 0");
>
> maybe migrate this to ethtool msg_level?
>

We investigated this and found that we cannot map all of our Infiniband
level communication errors etc to the ethtool message levels. One option could
be to add support for Ethtool message levels in addition to the vnic_debug
controlled messages. The Ethtool support would make this driver conform
to ethtool similar to other Ethernet drivers and the vnic_debug messages will
help in debugging the Infiniband related errors.

Is ethtool support mandatory for a merge to 2.6.27 or can we consider
it as a future
enhancement while we first focus on moving this driver to use CONFIGFS ?

Regards,
Ram
