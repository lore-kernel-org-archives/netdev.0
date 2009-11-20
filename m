From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: A generic kernel compatibilty code
Date: Fri, 20 Nov 2009 21:00:58 +0000
Message-ID: <1258750858.2877.58.camel@achroite.uk.solarflarecom.com>
References: <43e72e890911201245r4de5b039hb2dd5011dabf2399@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755824AbZKTVBB@vger.kernel.org>
In-Reply-To: <43e72e890911201245r4de5b039hb2dd5011dabf2399@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2009-11-20 at 12:45 -0800, Luis R. Rodriguez wrote:
> Everyone and their mother reinvents the wheel when it comes to
> backporting kernel modules. It a painful job and it seems to me an
> alternative is possible. If we can write generic compatibilty code for
> a new routine introduced on the next kernel how about just merging it
> to the kernel under some generic compat module. This would be
> completey ignored by everyone using the stable kernel but can be
> copied by anyone doing backport work.
> 
> So I'm thinking something as simple as a generic compat/comat.ko with
> compat-2.6.32.[ch] files.
> 
> We've already backported everything needed for wireless drivers under
> compat-wireless under this format down to even 2.6.25.
[...]

If you think 2.6.25 is old then I don't think you understand the scale
of the problem.

OEMs still expect us to support RHEL 4 (2.6.9) and SLES 9 (2.6.5) though
the latter will probably be dropped soon.  Some other vendors apparently
still need to support even 2.4 kernels!

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
