From: Scott Feldman <sfeldma@pobox.com>
Subject: Re: e1000 driver problem with Intel Pro/1000 MT adapter
Date: Sat, 04 Dec 2004 16:00:01 -0800
Message-ID: <1102204801.3343.68.camel@sfeldma-mobl.dsl-verizon.net>
References: <200412032325.iB3NPdG04693@xos037.xos.nl>
Reply-To: sfeldma@pobox.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jos Vos <jos@xos.nl>
In-Reply-To: <200412032325.iB3NPdG04693@xos037.xos.nl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-12-03 at 15:25, Jos Vos wrote:
> I have a problem with an Intel Pro/1000 MT 4-port card in a Supermicro
> (non-HT) Pentium 4 system using RHEL3 (2.4.21 kernel "the RH way") with
> the e1000 driver (I tried both the version supplied by RH and the
> newest 5.5.4 driver):

The 4-port card has two 82546 dual-port controllers behind a PCI-X
bridge.  Your symptoms suggest interrupt routing didn't get setup
correctly for the controllers behind the bridge.  I've seen more than
one case where the BIOS gets this wrong.  The fix is to upgrade to the
latest BIOS.  Hopefully this is the fix for you.  :-)

-scott
