From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [PATCH RESEND 1/3] netfilter: xtables: inclusion of
 xt_condition
Date: Tue, 21 Sep 2010 23:02:07 +0300
Message-ID: <1285099327.10579.20.camel@powerslave>
References: <1282034213-1829-1-git-send-email-luciano.coelho@nokia.com>
	 <1282034213-1829-2-git-send-email-luciano.coelho@nokia.com>
	 <4C912EFC.9070406@trash.net>
	 <alpine.LNX.2.01.1009152246320.5146@obet.zrqbmnf.qr>
	 <4C9133A0.7050601@trash.net>
	 <alpine.LNX.2.01.1009152309140.6445@obet.zrqbmnf.qr>
	 <4C91AD41.1020802@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"sameo@linux.intel.com" <sameo@linux.intel.com>,
	"Ylalehto Janne (Nokia-MS/Tampere)" <janne.ylalehto@nokia.com>
To: ext Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4C91AD41.1020802@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-09-16 at 07:38 +0200, ext Patrick McHardy wrote:
> On 15.09.2010 23:09, Jan Engelhardt wrote:
> > 
> > On Wednesday 2010-09-15 22:59, Patrick McHardy wrote:
> >> On 15.09.2010 22:52, Jan Engelhardt wrote:
> >>>
> >>> On Wednesday 2010-09-15 22:39, Patrick McHardy wrote:
> >>>> Am 17.08.2010 10:36, schrieb Luciano Coelho:
> >>>>> +/* Defaults, these can be overridden on the module command-line. */
> >>>>> +static unsigned int condition_list_perms = S_IRUGO | S_IWUSR;
> >>>>> +static unsigned int condition_uid_perms = 0;
> >>>>> +static unsigned int condition_gid_perms = 0;
> >>>>
> >>>> I'm not sure whether we already discussed this, but this isn't
> >>>> useful if namespaces are used since the IDs aren't global.
> >>>
> >>> Well it's also done for other xt modules that offer a procfs interface.
> >>> It does not really cost much to have this present I'd say.
> >>
> >> They should simply set the permissions for the current namespace.
> >>
> > IIRC, the namespace stuff was going to be a later patch to keep
> > early patches simpler.
> 
> I'm fine with that as long as its done before merging the patches
> upstream.

I'll try to fix this and create a new patch on top of the existing ones,
then I'll send them all as a single patchset.


-- 
Cheers,
Luca.

