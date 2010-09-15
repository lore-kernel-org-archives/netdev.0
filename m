From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH RESEND 1/3] netfilter: xtables: inclusion of
 xt_condition
Date: Wed, 15 Sep 2010 22:52:43 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1009152246320.5146@obet.zrqbmnf.qr>
References: <1282034213-1829-1-git-send-email-luciano.coelho@nokia.com> <1282034213-1829-2-git-send-email-luciano.coelho@nokia.com> <4C912EFC.9070406@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Luciano Coelho <luciano.coelho@nokia.com>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	sameo@linux.intel.com, janne.ylalehto@nokia.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4C912EFC.9070406@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wednesday 2010-09-15 22:39, Patrick McHardy wrote:
>Am 17.08.2010 10:36, schrieb Luciano Coelho:
>> +/* Defaults, these can be overridden on the module command-line. */
>> +static unsigned int condition_list_perms = S_IRUGO | S_IWUSR;
>> +static unsigned int condition_uid_perms = 0;
>> +static unsigned int condition_gid_perms = 0;
>
>I'm not sure whether we already discussed this, but this isn't
>useful if namespaces are used since the IDs aren't global.

Well it's also done for other xt modules that offer a procfs interface.
It does not really cost much to have this present I'd say.
