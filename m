From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: CVE-2014-9900 fix is not upstream
Date: Thu, 25 Aug 2016 16:14:02 +0100
Message-ID: <20160825161402.46f2ec9b@lxorguk.ukuu.org.uk>
References: <1471959668-18209-1-git-send-email-luis.henriques@canonical.com>
        <20160823.094029.1244944495918162255.davem@davemloft.net>
        <1471973727.13300.162.camel@decadent.org.uk>
        <20160823.112406.549221808236512285.davem@davemloft.net>
        <20160823200941.GB2356@ZenIV.linux.org.uk>
        <1471984445.3746.129.camel@perches.com>
        <20160823204933.GA14311@csclub.uwaterloo.ca>
        <20160823212545.GC2356@ZenIV.linux.org.uk>
        <20160824140316.GB14309@csclub.uwaterloo.ca>
        <18517b44-0d3f-3f83-e327-60064c170c5a@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
        Al Viro <viro@ZenIV.linux.org.uk>,
        Joe Perches <joe@perches.com>,
        David Miller <davem@davemloft.net>, ben@decadent.org.uk,
        luis.henriques@canonical.com, avijitnsec@codeaurora.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <18517b44-0d3f-3f83-e327-60064c170c5a@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > I see someone did request it 2 years ago:
> > https://gcc.gnu.org/bugzilla/show_bug.cgi?id=63479  
> 
> I don't think this is sufficient. Basically if you write one field in a
> struct after a memset again, the compiler is allowed by the standard to
> write padding bytes again, causing them to be undefined.

The question is simply what gcc actually does. The rest is C language
lawyering and since the kernel isn't written to the C language spec but
to gcc only gcc matters.

Alan
