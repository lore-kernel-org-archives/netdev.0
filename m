From: Michal =?utf-8?B?S3ViZcSNZWs=?= <mkubecek@suse.cz>
Subject: Re: [net-next 02/11] e1000: Adding e1000_dump function
Date: Mon, 13 Feb 2012 09:24:32 +0100
Message-ID: <8813313.EUCIY7NiG3@alaris>
References: <1328618038-5008-1-git-send-email-jeffrey.t.kirsher@intel.com> <1782836.alj52xdzPl@alaris> <061C8A8601E8EE4CA8D8FD6990CEA89123BDE6@ORSMSX102.amr.corp.intel.com>
Reply-To: Michal =?utf-8?B?S3ViZcSNZWs=?= <mkubecek@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jbeulich@suse.com" <jbeulich@suse.com>
To: "Dave, Tushar N" <tushar.n.dave@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:40306 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750978Ab2BMIYf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 03:24:35 -0500
In-Reply-To: <061C8A8601E8EE4CA8D8FD6990CEA89123BDE6@ORSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 08 of February 2012 18:39EN, Dave, Tushar N wrote:
> How did you fix the problem in e1000e then? I don't see bus_to_virt
> used in any of our Ethernet drivers.

We didn't, yet. I don't understand the memory mapping well enough to=20
propose a solution. We have run into this problem when we investigated =
a=20
different issue (repeated Tx hangs without apparent cause) and an=20
attempt to dump registers resulted in kernel crash.

                                                        Michal Kube=E8e=
k
