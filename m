From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Null pointer dereference in nl80211_set_reg
Date: Thu, 22 Aug 2013 17:04:45 +0100
Message-ID: <1377187485.1703.43.camel@bwh-desktop.uk.level5networks.com>
References: <20130822174121.18441b7f@x220>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Linux Network Mailing List" <netdev@vger.kernel.org>
To: <udo@hypervisor.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130822174121.18441b7f@x220>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-08-22 at 17:41 +0200, Udo Steinberg wrote:
> Hi all,
> 
> I'm running Linux 3.10.7 and have encountered the following NULL pointer
> dereference. So far it has only occurred once, so I cannot reproduce the
> circumstances that cause the problem.
> 
> Please keep me on CC: as I'm not subscribed to LKML.
[...]

Probably fixed by:

commit c319d50bfcf678c2857038276d9fab3c6646f3bf
Author: Johannes Berg <johannes.berg@intel.com>
Date:   Tue Jul 30 22:34:28 2013 +0200

    nl80211: fix another nl80211_fam.attrbuf race

which went into 3.10.8.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
