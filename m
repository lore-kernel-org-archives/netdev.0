From: Sean Neakums <sneakums@zork.net>
Subject: [2.6.0-test1-mm1] TCP connections over ipsec hang after a few
 seconds
Date: Sat, 19 Jul 2003 14:40:48 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <6uk7aeab33.fsf@zork.zork.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've just set up transport mode IPsec between two machines with the
aid of the LARTC IPsec docs.  Both boxes are running 2.6.0-test1-mm1,
with a wireless/wired bridge between, using ipsec-tools 0.2.2.
Everything seems to be in order, except (big except) that TCP sessions
hang after a small number of seconds of use, usually between ten and
twenty.  The problem seems unrelated to the amount of data
transferred; I've tried both bulk rsync transfers and ssh sessions.
I've also tested the same boxes over 100baseT; still happens.

I'm not exactly sure what additional information to supply; my
experience with IPsec is limited to this past few hours'
experimentation.
