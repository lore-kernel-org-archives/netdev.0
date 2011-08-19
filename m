From: Will de Bruijn <willemb@google.com>
Subject: Re: [PATCH] net: add Documentation/networking/scaling.txt
Date: Fri, 19 Aug 2011 15:50:55 -0400
Message-ID: <CA+FuTSdFbCuUy5YJOjST54qZpnrxJGdQD5M8y3nsw453L+o62g@mail.gmail.com>
References: <alpine.DEB.2.00.1107312346350.28722@pokey.mtv.corp.google.com>
 <4E36F524.7090301@hp.com> <1313524404.2725.50.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>, Tom Herbert <therbert@google.com>,
	rdunlap@xenotime.net, linux-doc@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1313524404.2725.50.camel@bwh-desktop>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> As I'm sure you're aware, there is often a trade-off between throughp=
ut
> and latency. =A0It might be useful to provide some guidelines for
> optimising each of the above.

The suggested configuration section on RSS already gives some vague
heuristics. In general, I hesitate to write down best guesses, and I
lack the hard experimental data that would make such advise more
sound.

> The default affinity for most IRQs is all-CPUs. =A0At least on x86, t=
hat
> really means CPU 0 only, so far as I can see.

Yes, I believe so, but since the specified behavior is all-CPUs and
other architectures are free to implement this differently, I prefer
to leave the weaker statement. Also, even on x86 there is the
possibility of migration, so starting on CPU0 is not equivalent to
having the affinity set to that CPU.

>> Requires that ntuple filtering be enabled?
> [...]
>
> As a matter of fact, n-tuple filtering is enabled by default where
> available. =A0So it might actually make more sense to say that RFS
> acceleration can be *disabled* by disabling n-tuple filtering using
> ethtool.

I didn't know (or check, clearly). I'll clarify that in a next
revision. Since the text is still factually correct and I don't want
to spam the list with frequent minor changes, I'll batch them.

Thanks, Ben.
