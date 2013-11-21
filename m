From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 7/8] openvswitch: Drop user features if old user
 space attempted to create datapath
Date: Thu, 21 Nov 2013 15:50:16 -0800
Message-ID: <CAEP_g=81rrqipxqC4i6qFQ7fvGpyR0cXOysx8gUmskvFoBZNDQ@mail.gmail.com>
References: <cover.1385057355.git.tgraf@suug.ch> <68ddfb6e0ef4401f246f2599ade5c15b25063736.1385057355.git.tgraf@suug.ch>
 <1385058197.1586.15.camel@bwh-desktop.uk.level5networks.com> <20131121222047.GA14252@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>, ffusco@redhat.com,
	fleitner@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog125.obsmtp.com ([74.125.149.153]:44683 "HELO
	na3sys009aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751508Ab3KUXuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 18:50:39 -0500
Received: by mail-ie0-f176.google.com with SMTP id at1so873850iec.21
        for <netdev@vger.kernel.org>; Thu, 21 Nov 2013 15:50:38 -0800 (PST)
In-Reply-To: <20131121222047.GA14252@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 21, 2013 at 2:20 PM, Thomas Graf <tgraf@suug.ch> wrote:
> On 11/21/13 at 06:23pm, Ben Hutchings wrote:
>> On Thu, 2013-11-21 at 19:13 +0100, Thomas Graf wrote:
>> > +
>> > +/**
>> > + * V2:
>>
>> This is not kernel-doc format so don't use '/**'.
>
> I was hoping kernel-doc would pick it up but it doesn't.
> I'll convert it.
>
>> > +           if (info->genlhdr->version < OVS_DP_VER_FEATURES) {
>> > +                   WARN_ONCE(dp->user_features, "Dropping previously "
>> > +                             "announced user features");
>>
>> Log messages shouldn't be split like this as it makes them harder to
>> find.  There should also be a newline at the end of the message.
>
> Right, I'll fix this up. We seem to have many of these unfixed.
>
> Jesse, do you want a full respin or just a v2 of this patch?

Whichever is easier is fine.
