From: Oussama Ghorbel <ou.ghorbel@gmail.com>
Subject: SIT Tunnel: Generate an ICMPV6 message and send them back to the
 original IPV6 node
Date: Fri, 11 Oct 2013 17:36:48 +0100
Message-ID: <CABfLueHiw+h99pHficnAtAwvsmqFBp7EakHuC=7WJeBG2QR7eQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In RFC 4213, section 3.4, page 11, it says:
If sufficient data bytes from the offending packet are available, the
encapsulator MAY extract the encapsulated IPv6 packet and use it to
generate an ICMPv6 message directed back to the originating IPv6  node.

Currently, linux does not do that.
More info on the RFC: http://tools.ietf.org/html/rfc4213
Issue described also in  https://bugzilla.kernel.org/show_bug.cgi?id=49761

I'm considering to implement this feature.
Will be interesting to do it?

Regards,
Oussama
