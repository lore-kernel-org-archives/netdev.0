From: "Justin Edwards" <justin@cview.com.au>
Subject: Win98 connecting to Samba
Date: Wed, 29 Jan 2003 17:59:55 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <b17u0d$7ol$1@main.gmane.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've been trying to connect my windows 98 pc to my linux machine with no
luck.

I have 2 machines with the following details:

Win98     192.168.1.1
Linux       192.168.1.2

I can ping both addresses from either end and can connect to both the linux
and
win98 machines from the linux pc using the smbclient command.
The linux machine is sharing its homes directory.

I can see the Linux machine name in my Network Neighborhood

I am using the same names between linux and win98 and have set the smb.conf
to use encryption. testparm appears ok.

I have added my users using the smbpasswd command

When I try net view from my W98 machine I see the computer:

\\linux
\\win98
If I try to "net view \\linux" I get the following nasty message:
"Error 53: The computer name specified in the network path cannot be
located. Make sure you are specifying the computer name correctly, or
try again
later when the remote computer is available."

If I click on Spanky from Network Neighborhood I see:
\\spanky not accessible.
The computer or sharename could not be found. Make sure you typed it
correctly, and try again.

My smb.conf file is as follows

[global]

workgroup = server
server string =  linux server
encrypt passwords = yes
smb passwd fie =  /etc/samba/smbpasswd

[homes]
comment = homes directory
browseable = yes
writable = yes

I would be grateful for any help you could provide me.

Regards
Justin Edwards
Justin@cview.com.au
