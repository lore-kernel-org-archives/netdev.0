From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: kernel crash with G5 Xserve and sungem driver
Date: Fri, 01 Oct 2004 10:35:52 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <415D8768.8080808@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linuxppc-dev@ozlabs.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I have patched 2.6.9-rc2 to run in 32-bit mode on the G5 Xserve.

When I compile a kernel with the tigon driver and the sungem driver both 
built-in, the kernel crashes.  Removing the sungem driver fixes the problem.

Is there a known incompatibility between the sungem driver and the Xserve?

I don't have crash output at the moment, but I can probably get it eventually.

Chris
