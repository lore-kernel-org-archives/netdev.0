From: Dan Williams <dcbw@redhat.com>
Subject: orinoco upstream merge to kernel status?
Date: Tue, 29 Mar 2005 10:29:09 -0500
Message-ID: <1112110149.16060.13.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: proski@gnu.org, hermes@gibson.dropbear.id.au
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I've just looked over the diff between current 2.6.12rc1 and upstream
"for_linus" branch of the orinoco drivers.  I found that the delta is
almost 100% due to monitor mode/scanning code that's found in the
upstream driver.  That's the last _important_ piece that has to get
merged to the mainline kernel.  It seems all the other trivial pieces
have been merged already.

David/Pavel: is it correct that the only bits left are monitor
mode/scanning, and that they cannot be separated?  Should that diff just
be posted as a patch to netdev?  Or are there other issues with the
"for_linus" branch right now that prevent the final merge from
occurring?

Dan
