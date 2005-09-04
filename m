From: pravin <pravin.shelar@gmail.com>
Subject: question abt equal cost multipath networking
Date: Mon, 5 Sep 2005 01:41:02 +0530
Message-ID: <bab43330050904131141534c42@mail.gmail.com>
Reply-To: pravin.shelar@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello everyone,
     I  am working on equal cost multipath networking code in Linux
kernel. I studied the device round robin algorithm for the same. The
drr algorithm examines use count of devices to select outgoing device.
The use count is defined as number of sessions opened on that device
up till now. But this does not necessarily give us current load on a
device. We can use some other metric to select the outgoing device
e.g. current device packet-queue length.
       So is there any specific reason for choosing use count as a
metric for this algorithm. Can I change this metric to some different
parameter e.g. device queue length or number of open sessions on a
device at present?

Thanks,
Pravin.

PS. I'm not on the list, so please CC me.
