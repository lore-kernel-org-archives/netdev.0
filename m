From: Hendrik Wiese <7.e.Q@syncro-community.de>
Subject: VME IP Driver Development - some questions
Date: Tue, 16 Nov 2004 08:44:52 +0100
Message-ID: <4199AFF4.60407@syncro-community.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

I have got some questions about driver development on Linux 2.6:

Is there somebody who can explain, what is meant with wait_event and 
wake_up? Does it mean,
when I run "ifconfig", and the driver says "wait_event", is "ifconfig" 
blocked until my driver which
is continuing his work says "wake_up"? Have I explained this correctly?

If I give wait_event a condition, is it right that the driver continues 
its work and ifconfig is
blocked until the driver does something that sets this condition true?

Something else: we need a driver, which establishes an IP layer on top 
of the VME bus
to transfer data via a network device (called dpn). On the other side 
this driver must be
able to communicate with passive modules inside the vme-rack by polling 
their shared
memory for data.

Is it possible to create two kernel modules which run with the same 
hardware? One
module for the communication with the active VME modules via IP and 
another one
for the communication with the passive VME modules by polling their 
shared memory?

Many questions, I know. But I am an absolute newbie in driver 
development. And I
hope you can help me.

If somebody knows a source of informations regarding this topic, which 
is held in
german, please tell me.

Thanks a lot

kind regards
Hendrik (Germany)
