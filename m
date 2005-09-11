From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.13-mm2
Date: Sun, 11 Sep 2005 02:07:25 +0200
Message-ID: <4323753D.9030007@trash.net>
References: <20050908053042.6e05882f.akpm@osdl.org>	<1126396015l.6300l.1l@werewolf.able.es> <20050910165659.5eea90d0.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "J.A. Magallon" <jamagallon@able.es>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932714AbVIKAHe@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20050910165659.5eea90d0.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> "J.A. Magallon" <jamagallon@able.es> wrote:
> 
>>I can not ifup an interface while iptables is using it.
>>Is this expected behaviour ?
> 
> Maybe it's expected, but breaking existing userspace is a serious issue.

No, its not expected.

>>There is a possible bug (IMHO) in Mandrake initscripts, that start iptables
>>before network interfaces, but this had always worked.
>>
>>Any ideas ?

What's happening when you try to set the interface up? Please
provide output of ifup and strace of the failing command. Thanks.
