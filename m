From: Carlos Martin <carlos@cmartin.tk>
Subject: [PATCH 0/7] acxsm: Make acxsm modular again (2nd try)
Date: Tue, 28 Feb 2006 17:30:13 +0100
Message-ID: <1141144213577-git-send-email-carlos@cmartin.tk>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Denis Vlasenko <vda@ilport.com.ua>,
	acx100-devel@lists.sourceforge.net,
	Christoph Hellwig <hch@infradead.org>
Return-path: <acx100-devel-admin@lists.sourceforge.net>
In-Reply-To: 
To: netdev@vger.kernel.org
Sender: acx100-devel-admin@lists.sourceforge.net
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

Hi,

There are a couple of differences between this and my previos patch,
so I'll list them here:

- Separate the patches properly

- This patchset uses the default generic functions and calls the
  appropiate function using a #define, which should be much clearer
  and saves us from having to migrate the whole common.c file.

- We get the proper string for the _debug family of functions.

- acx_ops.issue_cmd takes different functions depending on the debug
  level so we save a few bytes we weren't going to use otherwise. This
  also saves a function call.

- Denis' sense of style has been applied, though some of it doesn't
  apply anymore and some came from me trying to do too many things at
  once which screwed up the format. I hope these are alright.

 Kconfig      |   40 ++++++++++----------
 Makefile     |   15 +++++--
 acx_func.h   |  112 ++++++++++++++++++++--------------------------------=
------
 acx_struct.h |   32 ++++++++++++++--
 common.c     |  113 ++++++++++++++++++++++++++++------------------------=
-------
 ioctl.c      |    2 +
 pci.c        |   31 ++++++++++++++++
 usb.c        |   27 +++++++++++++-
 8 files changed, 212 insertions(+), 160 deletions(-)




-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
