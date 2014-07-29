From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [net-next 11/12] e1000e: Fix EEE in S5 w/ Runtime PM enabled
Date: Wed, 30 Jul 2014 00:11:23 +0200
Message-ID: <20140729221123.GA31298@electric-eye.fr.zoreil.com>
References: <1406349922-9883-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1406349922-9883-12-git-send-email-jeffrey.t.kirsher@intel.com>
 <20140726151005.GA20445@electric-eye.fr.zoreil.com>
 <2B0E3F215D1AB84DA946C8BEE234CCC9371476BC@ORSMSX104.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Wysocki, Rafael J" <rafael.j.wysocki@intel.com>
To: "Ertman, David M" <david.m.ertman@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:52567 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751758AbaG2WLf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 18:11:35 -0400
Content-Disposition: inline
In-Reply-To: <2B0E3F215D1AB84DA946C8BEE234CCC9371476BC@ORSMSX104.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ertman, David M <david.m.ertman@intel.com> :
[...]

Thanks for the explanation.

[...]
> According to Documentation/power/runtime_pm.txt and
> Documentation/power/pci.txt, the idle call-back is the correct place to
> put the check for applicability, and initiation, of a runtime suspend
> event. The duplication of effort between watchdog and runtime_idle is
> something that I need to explore. There are flow issues involved that will
> take some unraveling to fully evaluate.

I agree (almost: s/the correct place/a correct place/).

Rafael's e4fbce740f078bbc925ba5c86648d9c883968479 illustrated the shrinking
idle callback. It nicely trimmed some complexity between runtime PM and the
relevant driver. It may be of use.

--
Ueimor
