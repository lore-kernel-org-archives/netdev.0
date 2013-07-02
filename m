From: Neal Cardwell <ncardwell@google.com>
Subject: packetdrill: a scriptable network stack testing tool
Date: Tue, 2 Jul 2013 13:21:53 -0700
Message-ID: <CADVnQymNus-PXFpZQf3tsiGNeqUATgvOSRcVUMiUPsAzfA7WHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:64668 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754487Ab3GBUVz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 16:21:55 -0400
Received: by mail-ee0-f47.google.com with SMTP id e49so2920467eek.6
        for <netdev@vger.kernel.org>; Tue, 02 Jul 2013 13:21:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'd like to announce the availability of the packetdrill network stack
testing tool.

The packetdrill scripting tool enables users to quickly write precise
tests for entire TCP/UDP/IPv4/IPv6 network stacks, from the system
call layer down to the NIC hardware. packetdrill currently works on
Linux, FreeBSD, OpenBSD, and NetBSD. It can test network stack
behavior over physical NICs on a LAN, or on a single machine using a
tun virtual network device.

The code is licensed under version 2 of the GPL, and available in a
git repository at:

  https://code.google.com/p/packetdrill/

Here's a USENIX 2013 paper about the tool:

  http://research.google.com/pubs/pub41316.html

This paper describes the design and implementation of the tool, and
our experiences using it to execute 657 test cases. The tool was
instrumental in our development of three new features for Linux
TCP=97Early Retransmit, Fast Open, and Loss Probes=97and allowed us to
find and fix 10 bugs in Linux. Our team uses packetdrill in all phases
of the development process.

Currently the source for the testing tool is in the git repository,
along with an example script for each supported OS. We will also be
posting tests from our team's Linux TCP test suite (described in the
paper), as time permits.

There is a mailing list for questions, discussions and patches:

  http://groups.google.com/group/packetdrill

Enjoy!

neal
