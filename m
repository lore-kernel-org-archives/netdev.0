From: Atkinson Stephen-G19998 <satkinson@motorola.com>
Subject: ETH_P_ALL and "NIT"
Date: Wed, 18 May 2005 16:55:34 -0500
Message-ID: <5D454811D0A1D711A12A00065BF36FAD14D99A36@il06exm11>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I would like to be able to receive all packets (regardless of type) on a
given net_device. It seems the way to do this would be to use ETH_P_ALL
however, ETH_P_ALL has two meanings, 1) receive all packets and 2) behave
as a "NIT" (Network Interface Tap?). The NIT functionality causes packets
transmitted on the net_device in question to be "received" by the ETH_P_ALL
socket, unless the packet was sent by that socket.

I have a need to receive all incoming packets on a net_device however, for
my needs receiving transmitted packets is an undesirable side effect. So,
I'd like to propose a new ethernet type (ETH_P_ALL_NO_NIT perhaps) which 
would behave like ETH_P_ALL without NIT.

Comments? Does this sound reasonable? If so I'll submit a patch.

Thanks,
steve atkinson
