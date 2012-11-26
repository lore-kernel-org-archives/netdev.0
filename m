From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: iputils-s20121126
Date: Mon, 26 Nov 2012 21:13:54 +0900
Message-ID: <50B35D02.7020404@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:53063 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754142Ab2KZMN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 07:13:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

iputils-s20121126 comes with a lot of bug fixes and improvements.

New features and bux fixes (selected) since s20121114:
        - static link support for libidn.
        - arping: select default interface.
        - ninfod: rejects queries from global addresses.
        - ping: do not free uninitialized value (bug since s20121112).
        - ping6: -N subject-ipv6 and subject-ipv4 sub-options fixed.
        - ping6: Randomize nonce field in NI Queries.
        - ping6: source routing deprecated.
        - tracepath: broken if port was omitted (bug since s20121112).

Files:
        https://sourceforge.net/projects/iputils/files/
        http://www.skbuff.net/iputils/
Tree:
        http://www.linux-ipv6.org/gitweb/gitweb.cgi?p=gitroot/iputils.git
        https://sourceforge.net/p/iputils/code/ci/HEAD/tree/

Regards,

--yoshfuji
----------
Changelogs:

Jan Synacek (2):
      ping,ping6: Add newline to error message.
      ping: Don't free an unintialized value.

YOSHIFUJI Hideaki (69):
      arping,clockdiff,ping,rarpd,rdisc,traceroute6 doc:
s/CAP_NET_RAWIO/CAP_NET_RAW/.
      ping,ping6: Do not assume radix point is denoted by '.' (-i option).
      arping,ping,ping6,rdisc,traceroute6: Fix version string.
      makefile: Give -fno-strict-aliasing to compiler by default.
      ping6: Use SCOPE_DELIMITER.
      Makefile: Remove -lm from ADDLIB.
      rdisc_srv,Makefile: Fix build.
      rdisc_srv,Makefile: Build rdisc_srv with make all.
      arping: set_device_broadcast() does not need to store return value
of sub-functions.
      arping,Makefile: Make default interface configurable.
      arping: Do not allow empty device name (-I option).
      arping: Introduce check_ifflags() helper function.
      arping: Introduce device structure to hold output device information.
      arping: ALlow no default interface and select one by getifaddrs().
      arping: Introduce 2nd (legacy) method to select interface by ioctls.
      arping,Makefile: Allow build without getifaddrs() with
WITHOUT_IFADDRS=yes.
      Makefile: Use $< instead of $^ to complile C source code.
      ping,ping6: Reorder command-line options in alphabetical order.
      ping6: Show suboptions for Node Information Queries if -N
suboption is invalid.
      ping,ping6 doc: Readability for TOS (-Q) option.
      rdisc: Missing new line after usage.
      rdisc: Make rdisc with responder support if configured.
      Makefile: distclean depends on clean.
      Makefile: Default to -O3.
      Makefile: Minimize options to gcc.
      Makefile: Add rule to build assembly files.
      arping,Makefile: 3rd legacy implementation to check network devices.
      arping: Less ifdefs.
      rdisc doc: Document -r, -p and -T options.
      ping6: NI Subjecet address did not work (-N subject-{ipv6,ipv4]
suboptions).
      ping6: Ensure to detect subject type conflicts.
      iputils-s20121121
      ping6: Use IN6_IS_ADDR_UNSPECIFIED() instead of our own helper
function.
      ping6 doc: Explicitly describe ping6 is IPv6 version if ping.
      ping6: Deprecate source routing by default (RFC5095).
      ping6: Use RFC3542 functions and definition for source routing.
      ping6: Introduce niquery_is_enabled() for readability.
      arping doc: interface is optional (-I option).
      ping: Eliminate dirty hack to cope with ancient egcs bug.
      Makefile: Fix missing right parenthese in comment.
      arping: Fix build failure with USE_SYSFS=yes and/or
WITHOUT_IFADDRS=yes
      arping: Unify source files.
      arping: Reorder functions and comment out unsued code.
      arping,ping,ping6,tracepath,traceroute6 Makefile: Support static
link of libidn by USE_IDN=static.
      Makefile: Minimize statically linked libraries.
      ping6: Do not clear seq check array twice for NI.
      ping6: Use MD5_DIGEST_LENGTH instead of magic value 16.
      ping6: Introduce helper functions for nonce in NI.
      ping6: Introduce NI_NONCE_SIZE macro instead of magic value 8.
      ping6: Ensure to call srand() to get some randomness in NI Nonce.
      ping6: Generate different NI Nonce in each NI Query (Memory version).
      ping6: Generate different NI Nonce in each NI Query (MD5 version).
      ping6: Cache NI Nonce.
      ping6: Print 'sequence number' embedded in NI Nonce.
      ninfod: Do noy try to memcpy to self.
      ninfod Makefile: More precise dependencies.
      ninfod: Discard multicat packet outside linklocal scope.
      ninfod: Apply default policy to refuse queries from global addresses.
      ninfod: Normalize timespec for delay.
      ninfod: Fix double-free without pthreads.
      ninfod: Do not mix output from multiple threads.
      ninfod: Employ internal buffer in stderrlog() for common case.
      iputils-s20121125
      tracepath: Repair tracepath without -p option.
      tracepath,tracepath6: -p option in usage.
      ping,ping6: Use MAX_DUP_CHK directly, not using mx_dup_chk variable.
      ping,ping6: Abstract received bitmap macros/definitions.
      ping,ping6: Use __u64 or __u32 for bitmap.
      iputils-s20121126
