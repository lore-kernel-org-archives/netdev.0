From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: re L4 conntracking netns conversion
Date: Thu, 7 Mar 2013 13:50:45 +0200
Message-ID: <CACVxJT9mPb+Fh7gc-PYwC288sjJct+-s5bSZ783j_6tiTNJKMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Gao feng <gaofeng@cn.fujitsu.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lots of netns changes!

I can't verify right now, but unless I'm not mistaken,
every L4 protocol conversion is buggy/oopsable/remotely ddosable
because per-netns stuff is initialized after protocol is hooked into
master dispatcher.

See c296bb4d5d417d466c9bcc8afef68a3db5449a64.
