From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [PATCH] ieee1394: eth1394: use "firewire%d" instead of "eth%d" as
	interface name
Date: Mon, 25 May 2009 12:57:54 +0200
Message-ID: <ac3eb2510905250357qd72b0eel7cec2bd56f12f71@mail.gmail.com>
References: <tkrat.21c425cc195510c9@s5r6.in-berlin.de> <alpine.DEB.2.01.0905232309400.7424@bogon>
	<tkrat.6c3758bf0544a790@s5r6.in-berlin.de> <200905251033.09272.zzam@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-hotplug@vger.kernel.org,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Christian Kujau <lists@nerdbynature.de>,
	linux-kernel@vger.kernel.org,
	linux1394-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Matthias Schwarzott <zzam@gentoo.org>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <200905251033.09272.zzam@gentoo.org>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 25, 2009 at 10:33, Matthias Schwarzott <zzam@gentoo.org> wr=
ote:
> On Sonntag, 24. Mai 2009, Stefan Richter wrote:
>> Christian Kujau wrote at LKML:
>> > If the patch will be accepted at all and it's not too late to ask:=
 I'd
>> > vote for fw%d as well, "firefire" just looks too long, for me at l=
east.
>>
>> I think I'll leave the driver as it is.
>> As I just noticed, we would lose interface renaming by udev.
>> From udev/extras/rule_generator/75-persistent-net-generator.rules:
>>
>> =C2=A0 # device name whitelist
>> =C2=A0 KERNEL!=3D"eth*|ath*|wlan*[0-9]|msh*|ra*|sta*|ctc*|lcs*|hsi*"=
,
>> GOTO=3D"persistent_net_generator_end"
>>
>> Besides, if we can we should avoid fw%d because this will clash with
>> udev rules which match KERNEL=3D=3D"fw*", as in
>> udev/rules/redhat/40-redhat.rules.
>
> I suggest a subsystem match here, or generally some
> SUBSYSTEM!=3D"net", GOTO=3D"end_of_file"
> around almost all rule files that should not match on network interfa=
ces, as
> users can rename them to almost all crazy names.
>
> @Kay: Perhaps it could simplify some rulesets to have a special jump =
target or
> option to skip entiere rules files.

Not sure, if Fedora is using this rule file, there seems a lot of old
stuff in it. But the rule should be ignored for device without a
device node, when SYMLINK is given in the rule.

Kay
--
To unsubscribe from this list: send the line "unsubscribe linux-hotplug=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
