From: Linda Xie <lxie@us.ibm.com>
Subject: Re: Linking interfaces to slots
Date: Fri, 3 Oct 2003 08:39:44 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFF25AF7B0.51E82D90-ON87256DB4.00495F04@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@oss.sgi.com, netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Steve Modica <modica@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





Those information can be obtained by ls -l /sys/class/net/ethX. Here is a
example:


bigboylp4:/home/linda # ls -l /sys/class/net/eth*
/sys/class/net/eth0:
total 0
drwxr-xr-x    3 root     root            0 2003-10-02 18:52 .
drwxr-xr-x    6 root     root            0 2003-10-02 18:52 ..
-r--r--r--    1 root     root         4096 2003-10-02 18:52 addr_len
-r--r--r--    1 root     root         4096 2003-10-02 18:52 address
-r--r--r--    1 root     root         4096 2003-10-02 18:52 broadcast
lrwxrwxrwx    1 root     root           53 2003-10-02 18:52 device ->
../../../devices/pci0005:00/0005:00:0b.2/0005:21:01.0 <-- pci dev
lrwxrwxrwx    1 root     root           29 2003-10-02 18:52 driver ->
../../../bus/pci/drivers/e100
-r--r--r--    1 root     root         4096 2003-10-02 18:52 features
-rw-r--r--    1 root     root         4096 2003-10-02 18:52 flags
-r--r--r--    1 root     root         4096 2003-10-02 18:52 ifindex
-r--r--r--    1 root     root         4096 2003-10-02 18:52 iflink
-rw-r--r--    1 root     root         4096 2003-10-02 18:52 mtu
drwxr-xr-x    2 root     root            0 2003-10-02 18:52 statistics
-rw-r--r--    1 root     root         4096 2003-10-02 18:52 tx_queue_len
-r--r--r--    1 root     root         4096 2003-10-02 18:52 type



/sys/class/net/eth1:
total 0
drwxr-xr-x    3 root     root            0 2003-10-02 19:51 .
drwxr-xr-x    6 root     root            0 2003-10-02 18:52 ..
-r--r--r--    1 root     root         4096 2003-10-02 19:51 addr_len
-r--r--r--    1 root     root         4096 2003-10-02 19:51 address
-r--r--r--    1 root     root         4096 2003-10-02 19:51 broadcast
lrwxrwxrwx    1 root     root           53 2003-10-02 19:51 device ->
../../../devices/pci0005:00/0005:00:0b.6/0005:61:01.0 <-- pci dev
lrwxrwxrwx    1 root     root           29 2003-10-02 19:51 driver ->
../../../bus/pci/drivers/e100
-r--r--r--    1 root     root         4096 2003-10-02 19:51 features
-rw-r--r--    1 root     root         4096 2003-10-02 19:51 flags
-r--r--r--    1 root     root         4096 2003-10-02 19:51 ifindex
-r--r--r--    1 root     root         4096 2003-10-02 19:51 iflink
-rw-r--r--    1 root     root         4096 2003-10-02 19:51 mtu
drwxr-xr-x    2 root     root            0 2003-10-02 19:51 statistics
-rw-r--r--    1 root     root         4096 2003-10-02 19:51 tx_queue_len
-r--r--r--    1 root     root         4096 2003-10-02 19:51 type
bigboylp4:/home/linda #


 There are two ethernet adapters,  eth0 and eth1, in the system. In PCI
world, eth0 is 0005:21:01.0 and eth1 is pci_dev 0005:61:01.0.


A shell script can be used for  greping ethX info,  then parsing the info
and generating a nice formatted output.

Linda
