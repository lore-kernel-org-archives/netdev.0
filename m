From: David Mosberger <davidm@napali.hpl.hp.com>
Subject: Re: status of ipchains in 2.6?
Date: Tue, 28 Oct 2003 09:56:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16286.44522.275791.73904@napali.hpl.hp.com>
References: <200310280127.h9S1RM5d002140@napali.hpl.hp.com>
	<20031028015032.734caf21.davem@redhat.com>
Reply-To: davidm@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davidm@hpl.hp.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.or.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031028015032.734caf21.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>>> On Tue, 28 Oct 2003 01:50:32 -0800, "David S. Miller" <davem@redhat.com> said:

  DaveM> On Mon, 27 Oct 2003 17:27:22 -0800 David Mosberger
  DaveM> <davidm@napali.hpl.hp.com> wrote:

  >> I recently discovered that ipchains is rather broken.  I noticed
  >> the problem on ia64, but suspect that it's likely to affect all
  >> 64-bit platforms (if not 32-bit platforms).  A more detailed
  >> description of the problem I'm seeing is here:

  >> http://tinyurl.com/sm9d

  >> Unlike ipchains, iptables works perfectly fine, so perhaps we
  >> just need to update Kconfig to discourage ipchains on ia64
  >> (and/or other 64-bit platforms)?

  DaveM> Might want to post this to the netfilter lists or netdev....
  DaveM> Nah, that might actually get the bug fixed.

$ fgrep -i ipchain MAINTAINERS
$

Might want to consider updating the MAINTAINERS file?

	--david
