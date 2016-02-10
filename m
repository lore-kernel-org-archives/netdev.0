From: John Holland <jotihojr@gmail.com>
Subject: Re: [Intel-wired-lan] [next] igb: allow setting MAC address on i211 using a device tree blob
Date: Wed, 10 Feb 2016 09:50:50 +0100
Message-ID: <0D415283-34B1-498E-9783-51BACD961963@gmail.com>
References: <56ABE3A8.4010602@gmail.com> <1455015744.3592.46.camel@intel.com> <20160209115921.GE18781@lunn.ch> <CAP-MU4Mr5SkpC9XZuPa5xaAjgJ+_j3Gt5hYcSO6a2Q7jVB8HcQ@mail.gmail.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Andrew Lunn <andrew@lunn.ch>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Shannon Nelson <shannon.nelson@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:34409 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750AbcBJIu5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 03:50:57 -0500
Received: by mail-wm0-f48.google.com with SMTP id 128so17026072wmz.1
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2016 00:50:57 -0800 (PST)
In-Reply-To: <CAP-MU4Mr5SkpC9XZuPa5xaAjgJ+_j3Gt5hYcSO6a2Q7jVB8HcQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Feb 9, 2016, at 18:42, Shannon Nelson <shannon.nelson@intel.com> wrote:
> 
> It seem to me this should be using eth_platform_get_mac_address(), a
> slightly more generic method to do this.  See the i40e driver for an
> example, commit d9a84324e6 I believe.
> 
I believe you are referring to https://patchwork.ozlabs.org/patch/566806. Haven't seen this used upstream yet. And, does that not mandate CONFIG_OF?

John
