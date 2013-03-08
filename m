From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: re L4 conntracking netns conversion
Date: Fri, 08 Mar 2013 09:01:36 +0800
Message-ID: <51393870.1030709@cn.fujitsu.com>
References: <CACVxJT9mPb+Fh7gc-PYwC288sjJct+-s5bSZ783j_6tiTNJKMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CACVxJT9mPb+Fh7gc-PYwC288sjJct+-s5bSZ783j_6tiTNJKMg@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2013/03/07 19:50, Alexey Dobriyan wrote:
> Lots of netns changes!
> 
> I can't verify right now, but unless I'm not mistaken,
> every L4 protocol conversion is buggy/oopsable/remotely ddosable
> because per-netns stuff is initialized after protocol is hooked into
> master dispatcher.
> 

Doesn't we do register_pernet_subsys before we register hooks and l4proto?
Sorry I don't quite understand what you mean. :(

> See c296bb4d5d417d466c9bcc8afef68a3db5449a64.
> 

