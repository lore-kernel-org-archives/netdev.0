From: "David Geller" <yedok@hotmail.com>
Subject: Why no dead gateway detection for Multipath routes?
Date: Fri, 22 Aug 2003 12:20:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <BAY7-F42xpTljBOh8s4000226dd@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-net@vger.kernel.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Why doesn't linux do dead gateway detection for multipath routes? To be more 
specific, why isn't something like fib_detect_death() called inside 
fib_select_multipath(), whereas it is called in fib_select_default()?

Isn't this a violation of the MUST part of section 3.3.1.4 of RFC 1122?

3.3.1.4 Dead Gateway Detection

The IP layer MUST be able to detect the failure of a "next- hop" gateway 
that is listed in its route cache and to choose an alternate gateway (see 
Section 3.3.1.5).

_________________________________________________________________
Enter for your chance to IM with Bon Jovi, Seal, Bow Wow, or Mary J Blige 
using MSN Messenger http://www.msnmessenger-download.com/imastar
