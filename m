From: David Mosberger <davidm@napali.hpl.hp.com>
Subject: Re: SOMAXCONN too low
Date: Wed, 29 Oct 2003 11:15:49 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16288.4581.143121.899848@napali.hpl.hp.com>
References: <200310290658.h9T6w04k015302@napali.hpl.hp.com>
	<20031029105809.0a1f27a1.davem@redhat.com>
Reply-To: davidm@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davidm@hpl.hp.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031029105809.0a1f27a1.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>>> On Wed, 29 Oct 2003 10:58:09 -0800, "David S. Miller" <davem@redhat.com> said:

  DaveM> On Tue, 28 Oct 2003 22:58:00 -0800 David Mosberger
  DaveM> <davidm@napali.hpl.hp.com> wrote:

  >> You obviously want some control over how big the listen queue can
  >> grow, but it seems to me that a sysctl would be in place.  I
  >> found this patch to do that, but no reaction to it:

  >> http://www.ussg.iu.edu/hypermail/linux/kernel/0205.0/1287.html

  DaveM> I think I'm going to apply this patch.

  DaveM> People can then set the limit to what they want, the default
  DaveM> stays at 128, and the SOMAXCONN define itself does not
  DaveM> change.

  DaveM> Ok David?

Yup.

Thanks!

	--david
