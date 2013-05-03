From: Berge Schwebs =?utf-8?Q?Bj=C3=B8rlo?= <berge@trivini.no>
Subject: Re: [BUG] ipv6 and TSO on GRE is broken
Date: Fri, 3 May 2013 16:52:49 +0200
Message-ID: <20130503145248.GF31654@trivini.no>
References: <1367423622.11020.54.camel@edumazet-glaptop>
 <CALnjE+pPmsJx6zqcA7PnR3GX3HUrrtCbZyqj7nyEDBCv9_Tntw@mail.gmail.com>
 <CALnjE+pvvHccEZZhH9ejCk4XGeTnWjupAFNfxvSAGdrOpHWhkg@mail.gmail.com>
 <20130502083245.GD31654@trivini.no>
 <CALnjE+qn8oaczOu0rRwcxhdmhaPSzVJgdhQ7un6yQC7og=fknQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"Steinar H. Gunderson" <sesse@google.com>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([193.35.52.29]:43504 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932905Ab3ECOwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 10:52:54 -0400
Content-Disposition: inline
In-Reply-To: <CALnjE+qn8oaczOu0rRwcxhdmhaPSzVJgdhQ7un6yQC7og=fknQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 02, 2013 at 07:17:57PM -0700, Pravin Shelar wrote:
> On Thu, May 2, 2013 at 1:32 AM, Berge Schwebs Bj=C3=B8rlo <berge@triv=
ini.no>
> wrote:
>> I'm not sure if we're talking about the same issue, but I'm experien=
cing
>> massive packet drops with outbound IPv6 traffic with a GREv4 tunnel =
with
>> IPv6 traffic on the inside. Inbound traffic seems fine, and IPv4 ins=
ide
>> the tunnel is fine in both directions.
> I posted fix on netdev.

The patch fixes my issues. Thanks!

-B

--=20
Berge Schwebs Bj=C3=B8rlo
Alegr=C3=ADa!
