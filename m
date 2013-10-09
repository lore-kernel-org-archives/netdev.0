From: Oliver Neukum <oliver@neukum.org>
Subject: MBIM device refusing to be enabled
Date: Wed, 09 Oct 2013 10:59:40 +0200
Message-ID: <1381309180.3464.2.camel@linux-fkkt.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:44902 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751954Ab3JII7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 04:59:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

I have a device which the kernel and MM (1.0) identify as MBIM.
I can transfer the PIN, but the device refuses to be enabled.
Any idea?

	Regards
		Oliver


2013-10-09T10:47:29.178266+02:00 linux-3m4i ModemManager[566]: <info>
logging: level 'DEBUG'
2013-10-09T10:47:38.225349+02:00 linux-3m4i dbus[559]: [system]
Activating service name='org.freedesktop.PackageKit' (using
servicehelper)
2013-10-09T10:47:38.740641+02:00 linux-3m4i dbus[559]: [system]
Successfully activated service 'org.freedesktop.PackageKit'
2013-10-09T10:47:52.007437+02:00 linux-3m4i ModemManager[566]: <debug>
Sending PIN...
2013-10-09T10:47:52.007696+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Sent message...#012<<<<<< RAW:#012<<<<<<   length =
80#012<<<<<<   data   =
03:00:00:00:50:00:00:00:0C:00:00:00:01:00:00:00:00:00:00:00:A2:89:CC:33:BC:BB:8B:4F:B6:B0:13:3E:C2:AA:E6:DF:04:00:00:00:01:00:00:00:20:00:00:00:02:00:00:00:00:00:00:00:18:00:00:00:08:00:00:00:00:00:00:00:00:00:00:00:34:00:35:00:36:00:37:00
2013-10-09T10:47:52.007858+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Sent message (translated)...#012<<<<<< Header:#012<<<<<<
length      = 80#012<<<<<<   type        = command
(0x00000003)#012<<<<<<   transaction = 12#012<<<<<< Fragment
header:#012<<<<<<   total   = 1#012<<<<<<   current = 0#012<<<<<<
Contents:#012<<<<<<   service =
'basic-connect' (a289cc33-bcbb-8b4f-b6b0-133ec2aae6df)#012<<<<<<   cid
= 'pin' (0x00000004)#012<<<<<<   type    = 'set' (0x00000001)
2013-10-09T10:47:52.523386+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Received message...#012>>>>>> RAW:#012>>>>>>   length =
60#012>>>>>>   data   =
03:00:00:80:3C:00:00:00:0C:00:00:00:01:00:00:00:00:00:00:00:A2:89:CC:33:BC:BB:8B:4F:B6:B0:13:3E:C2:AA:E6:DF:04:00:00:00:00:00:00:00:0C:00:00:00:03:00:00:00:01:00:00:00:03:00:00:00
2013-10-09T10:47:52.523709+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Received message (translated)...#012>>>>>>
Header:#012>>>>>>   length      = 60#012>>>>>>   type        =
command-done (0x80000003)#012>>>>>>   transaction = 12#012>>>>>>
Fragment header:#012>>>>>>   total   = 1#012>>>>>>   current =
0#012>>>>>> Contents:#012>>>>>>   status error =
'None' (0x00000000)#012>>>>>>   service      =
'basic-connect' (a289cc33-bcbb-8b4f-b6b0-133ec2aae6df)#012>>>>>>   cid
= 'pin' (0x00000004)
2013-10-09T10:47:52.523917+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Sent message...#012<<<<<< RAW:#012<<<<<<   length =
48#012<<<<<<   data   =
03:00:00:00:30:00:00:00:0D:00:00:00:01:00:00:00:00:00:00:00:A2:89:CC:33:BC:BB:8B:4F:B6:B0:13:3E:C2:AA:E6:DF:02:00:00:00:00:00:00:00:00:00:00:00
2013-10-09T10:47:52.524080+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Sent message (translated)...#012<<<<<< Header:#012<<<<<<
length      = 48#012<<<<<<   type        = command
(0x00000003)#012<<<<<<   transaction = 13#012<<<<<< Fragment
header:#012<<<<<<   total   = 1#012<<<<<<   current = 0#012<<<<<<
Contents:#012<<<<<<   service =
'basic-connect' (a289cc33-bcbb-8b4f-b6b0-133ec2aae6df)#012<<<<<<   cid
= 'subscriber-ready-status' (0x00000002)#012<<<<<<   type    =
'query' (0x00000000)
2013-10-09T10:47:54.155263+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Received message...#012>>>>>> RAW:#012>>>>>>   length =
112#012>>>>>>   data   =
07:00:00:80:70:00:00:00:00:00:00:00:01:00:00:00:00:00:00:00:A2:89:CC:33:BC:BB:8B:4F:B6:B0:13:3E:C2:AA:E6:DF:02:00:00:00:44:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:1C:00:00:00:26:00:00:00:00:00:00:00:00:00:00:00:38:00:39:00:34:00:39:00:32:00:32:00:36:00:30:00:37:00:30:00:36:00:39:00:32:00:31:00:34:00:35:00:39:00:34:00:30:00:00:00
2013-10-09T10:47:54.156023+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Received message (translated)...#012>>>>>>
Header:#012>>>>>>   length      = 112#012>>>>>>   type        =
indicate-status (0x80000007)#012>>>>>>   transaction = 0#012>>>>>>
Fragment header:#012>>>>>>   total   = 1#012>>>>>>   current =
0#012>>>>>> Contents:#012>>>>>>   service =
'basic-connect' (a289cc33-bcbb-8b4f-b6b0-133ec2aae6df)#012>>>>>>   cid
= 'subscriber-ready-status' (0x00000002)
2013-10-09T10:47:54.219500+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Received message...#012>>>>>> RAW:#012>>>>>>   length =
116#012>>>>>>   data   =
03:00:00:80:74:00:00:00:0D:00:00:00:01:00:00:00:00:00:00:00:A2:89:CC:33:BC:BB:8B:4F:B6:B0:13:3E:C2:AA:E6:DF:02:00:00:00:00:00:00:00:44:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:1C:00:00:00:26:00:00:00:00:00:00:00:00:00:00:00:38:00:39:00:34:00:39:00:32:00:32:00:36:00:30:00:37:00:30:00:36:00:39:00:32:00:31:00:34:00:35:00:39:00:34:00:30:00:00:00
2013-10-09T10:47:54.220527+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Received message (translated)...#012>>>>>>
Header:#012>>>>>>   length      = 116#012>>>>>>   type        =
command-done (0x80000003)#012>>>>>>   transaction = 13#012>>>>>>
Fragment header:#012>>>>>>   total   = 1#012>>>>>>   current =
0#012>>>>>> Contents:#012>>>>>>   status error =
'None' (0x00000000)#012>>>>>>   service      =
'basic-connect' (a289cc33-bcbb-8b4f-b6b0-133ec2aae6df)#012>>>>>>   cid
= 'subscriber-ready-status' (0x00000002)            
2013-10-09T10:47:55.147385+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Received message...#012>>>>>> RAW:#012>>>>>>   length =
144#012>>>>>>   data   =
07:00:00:80:90:00:00:00:00:00:00:00:01:00:00:00:00:00:00:00:A2:89:CC:33:BC:BB:8B:4F:B6:B0:13:3E:C2:AA:E6:DF:02:00:00:00:64:00:00:00:01:00:00:00:1C:00:00:00:1E:00:00:00:3C:00:00:00:26:00:00:00:00:00:00:00:00:00:00:00:32:00:36:00:32:00:30:00:37:00:33:00:39:00:34:00:37:00:36:00:32:00:34:00:36:00:31:00:34:00:00:00:38:00:39:00:34:00:39:00:32:00:32:00:36:00:30:00:37:00:30:00:36:00:39:00:32:00:31:00:34:00:35:00:39:00:34:00:30:00:00:00                                                                                                                                                                                                                              
2013-10-09T10:47:55.156021+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Received message (translated)...#012>>>>>>
Header:#012>>>>>>   length      = 144#012>>>>>>   type        =
indicate-status (0x80000007)#012>>>>>>   transaction = 0#012>>>>>>
Fragment header:#012>>>>>>   total   = 1#012>>>>>>   current =
0#012>>>>>> Contents:#012>>>>>>   service =
'basic-connect' (a289cc33-bcbb-8b4f-b6b0-133ec2aae6df)#012>>>>>>   cid
=
'subscriber-ready-status' (0x00000002)                                                                   
2013-10-09T10:47:55.156724+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Sent message...#012<<<<<< RAW:#012<<<<<<   length =
48#012<<<<<<   data   =
03:00:00:00:30:00:00:00:0E:00:00:00:01:00:00:00:00:00:00:00:A2:89:CC:33:BC:BB:8B:4F:B6:B0:13:3E:C2:AA:E6:DF:02:00:00:00:00:00:00:00:00:00:00:00                                                                                                                                                                                                                                                    
2013-10-09T10:47:55.157383+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Sent message (translated)...#012<<<<<< Header:#012<<<<<<
length      = 48#012<<<<<<   type        = command
(0x00000003)#012<<<<<<   transaction = 14#012<<<<<< Fragment
header:#012<<<<<<   total   = 1#012<<<<<<   current = 0#012<<<<<<
Contents:#012<<<<<<   service =
'basic-connect' (a289cc33-bcbb-8b4f-b6b0-133ec2aae6df)#012<<<<<<   cid
= 'subscriber-ready-status' (0x00000002)#012<<<<<<   type    =
'query' (0x00000000)                                    
2013-10-09T10:47:55.371469+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Received message...#012>>>>>> RAW:#012>>>>>>   length =
148#012>>>>>>   data   =
03:00:00:80:94:00:00:00:0E:00:00:00:01:00:00:00:00:00:00:00:A2:89:CC:33:BC:BB:8B:4F:B6:B0:13:3E:C2:AA:E6:DF:02:00:00:00:00:00:00:00:64:00:00:00:01:00:00:00:1C:00:00:00:1E:00:00:00:3C:00:00:00:26:00:00:00:00:00:00:00:00:00:00:00:32:00:36:00:32:00:30:00:37:00:33:00:39:00:34:00:37:00:36:00:32:00:34:00:36:00:31:00:34:00:00:00:38:00:39:00:34:00:39:00:32:00:32:00:36:00:30:00:37:00:30:00:36:00:39:00:32:00:31:00:34:00:35:00:39:00:34:00:30:00:00:00                                                                                                                                                                                                                  
2013-10-09T10:47:55.382816+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Received message (translated)...#012>>>>>>
Header:#012>>>>>>   length      = 148#012>>>>>>   type        =
command-done (0x80000003)#012>>>>>>   transaction = 14#012>>>>>>
Fragment header:#012>>>>>>   total   = 1#012>>>>>>   current =
0#012>>>>>> Contents:#012>>>>>>   status error =
'None' (0x00000000)#012>>>>>>   service      =
'basic-connect' (a289cc33-bcbb-8b4f-b6b0-133ec2aae6df)#012>>>>>>   cid
= 'subscriber-ready-status' (0x00000002)            
2013-10-09T10:47:55.383892+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Sent message...#012<<<<<< RAW:#012<<<<<<   length =
48#012<<<<<<   data   =
03:00:00:00:30:00:00:00:0F:00:00:00:01:00:00:00:00:00:00:00:A2:89:CC:33:BC:BB:8B:4F:B6:B0:13:3E:C2:AA:E6:DF:04:00:00:00:00:00:00:00:00:00:00:00                                                                                                                                                                                                                                                    
2013-10-09T10:47:55.384610+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Sent message (translated)...#012<<<<<< Header:#012<<<<<<
length      = 48#012<<<<<<   type        = command
(0x00000003)#012<<<<<<   transaction = 15#012<<<<<< Fragment
header:#012<<<<<<   total   = 1#012<<<<<<   current = 0#012<<<<<<
Contents:#012<<<<<<   service =
'basic-connect' (a289cc33-bcbb-8b4f-b6b0-133ec2aae6df)#012<<<<<<   cid
= 'pin' (0x00000004)#012<<<<<<   type    =
'query' (0x00000000)                                                        
2013-10-09T10:47:55.403320+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Received message...#012>>>>>> RAW:#012>>>>>>   length =
60#012>>>>>>   data   =
03:00:00:80:3C:00:00:00:0F:00:00:00:01:00:00:00:00:00:00:00:A2:89:CC:33:BC:BB:8B:4F:B6:B0:13:3E:C2:AA:E6:DF:04:00:00:00:00:00:00:00:0C:00:00:00:03:00:00:00:01:00:00:00:03:00:00:00                                                                                                                                                                                                            
2013-10-09T10:47:55.404271+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Received message (translated)...#012>>>>>>
Header:#012>>>>>>   length      = 60#012>>>>>>   type        =
command-done (0x80000003)#012>>>>>>   transaction = 15#012>>>>>>
Fragment header:#012>>>>>>   total   = 1#012>>>>>>   current =
0#012>>>>>> Contents:#012>>>>>>   status error =
'None' (0x00000000)#012>>>>>>   service      =
'basic-connect' (a289cc33-bcbb-8b4f-b6b0-133ec2aae6df)#012>>>>>>   cid
= 'pin' (0x00000004)                                 
2013-10-09T10:47:55.404934+02:00 linux-3m4i ModemManager[566]: <debug>
SIM is ready, and no need for the after SIM unlock
step...                                                                                                                                              
2013-10-09T10:47:55.405665+02:00 linux-3m4i ModemManager[566]: <info>
Modem /org/freedesktop/ModemManager1/Modem/0: state changed (locked ->
initializing)                                                                                                                    
2013-10-09T10:47:55.406433+02:00 linux-3m4i ModemManager[566]: <debug>
Couldn't start parent initialization: Couldn't open ports during modem
initialization: Couldn't get primary
port                                                                                        
2013-10-09T10:47:55.407267+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Sent message...#012<<<<<< RAW:#012<<<<<<   length =
48#012<<<<<<   data   =
03:00:00:00:30:00:00:00:10:00:00:00:01:00:00:00:00:00:00:00:A2:89:CC:33:BC:BB:8B:4F:B6:B0:13:3E:C2:AA:E6:DF:02:00:00:00:00:00:00:00:00:00:00:00                                                                                                                                                                                                                                                    
2013-10-09T10:47:55.408019+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Sent message (translated)...#012<<<<<< Header:#012<<<<<<
length      = 48#012<<<<<<   type        = command
(0x00000003)#012<<<<<<   transaction = 16#012<<<<<< Fragment
header:#012<<<<<<   total   = 1#012<<<<<<   current = 0#012<<<<<<
Contents:#012<<<<<<   service =
'basic-connect' (a289cc33-bcbb-8b4f-b6b0-133ec2aae6df)#012<<<<<<   cid
= 'subscriber-ready-status' (0x00000002)#012<<<<<<   type    =
'query' (0x00000000)
2013-10-09T10:47:55.723474+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Received message...#012>>>>>> RAW:#012>>>>>>   length =
148#012>>>>>>   data   =
03:00:00:80:94:00:00:00:10:00:00:00:01:00:00:00:00:00:00:00:A2:89:CC:33:BC:BB:8B:4F:B6:B0:13:3E:C2:AA:E6:DF:02:00:00:00:00:00:00:00:64:00:00:00:01:00:00:00:1C:00:00:00:1E:00:00:00:3C:00:00:00:26:00:00:00:00:00:00:00:00:00:00:00:32:00:36:00:32:00:30:00:37:00:33:00:39:00:34:00:37:00:36:00:32:00:34:00:36:00:31:00:34:00:00:00:38:00:39:00:34:00:39:00:32:00:32:00:36:00:30:00:37:00:30:00:36:00:39:00:32:00:31:00:34:00:35:00:39:00:34:00:30:00:00:00
2013-10-09T10:47:55.730738+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Received message (translated)...#012>>>>>>
Header:#012>>>>>>   length      = 148#012>>>>>>   type        =
command-done (0x80000003)#012>>>>>>   transaction = 16#012>>>>>>
Fragment header:#012>>>>>>   total   = 1#012>>>>>>   current =
0#012>>>>>> Contents:#012>>>>>>   status error =
'None' (0x00000000)#012>>>>>>   service      =
'basic-connect' (a289cc33-bcbb-8b4f-b6b0-133ec2aae6df)#012>>>>>>   cid
= 'subscriber-ready-status' (0x00000002)
2013-10-09T10:47:55.731038+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Sent message...#012<<<<<< RAW:#012<<<<<<   length =
48#012<<<<<<   data   =
03:00:00:00:30:00:00:00:11:00:00:00:01:00:00:00:00:00:00:00:A2:89:CC:33:BC:BB:8B:4F:B6:B0:13:3E:C2:AA:E6:DF:02:00:00:00:00:00:00:00:00:00:00:00
2013-10-09T10:47:55.731245+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Sent message (translated)...#012<<<<<< Header:#012<<<<<<
length      = 48#012<<<<<<   type        = command
(0x00000003)#012<<<<<<   transaction = 17#012<<<<<< Fragment
header:#012<<<<<<   total   = 1#012<<<<<<   current = 0#012<<<<<<
Contents:#012<<<<<<   service =
'basic-connect' (a289cc33-bcbb-8b4f-b6b0-133ec2aae6df)#012<<<<<<   cid
= 'subscriber-ready-status' (0x00000002)#012<<<<<<   type    =
'query' (0x00000000)
2013-10-09T10:47:55.819357+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Received message...#012>>>>>> RAW:#012>>>>>>   length =
92#012>>>>>>   data   =
07:00:00:80:5C:00:00:00:00:00:00:00:01:00:00:00:00:00:00:00:A2:89:CC:33:BC:BB:8B:4F:B6:B0:13:3E:C2:AA:E6:DF:09:00:00:00:30:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:01:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:02:00:00:00
2013-10-09T10:47:55.820197+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Received message (translated)...#012>>>>>>
Header:#012>>>>>>   length      = 92#012>>>>>>   type        =
indicate-status (0x80000007)#012>>>>>>   transaction = 0#012>>>>>>
Fragment header:#012>>>>>>   total   = 1#012>>>>>>   current =
0#012>>>>>> Contents:#012>>>>>>   service =
'basic-connect' (a289cc33-bcbb-8b4f-b6b0-133ec2aae6df)#012>>>>>>   cid
= 'register-state' (0x00000009)
2013-10-09T10:47:56.011348+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Received message...#012>>>>>> RAW:#012>>>>>>   length =
148#012>>>>>>   data   =
03:00:00:80:94:00:00:00:11:00:00:00:01:00:00:00:00:00:00:00:A2:89:CC:33:BC:BB:8B:4F:B6:B0:13:3E:C2:AA:E6:DF:02:00:00:00:00:00:00:00:64:00:00:00:01:00:00:00:1C:00:00:00:1E:00:00:00:3C:00:00:00:26:00:00:00:00:00:00:00:00:00:00:00:32:00:36:00:32:00:30:00:37:00:33:00:39:00:34:00:37:00:36:00:32:00:34:00:36:00:31:00:34:00:00:00:38:00:39:00:34:00:39:00:32:00:32:00:36:00:30:00:37:00:30:00:36:00:39:00:32:00:31:00:34:00:35:00:39:00:34:00:30:00:00:00
2013-10-09T10:47:56.019690+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Received message (translated)...#012>>>>>>
Header:#012>>>>>>   length      = 148#012>>>>>>   type        =
command-done (0x80000003)#012>>>>>>   transaction = 17#012>>>>>>
Fragment header:#012>>>>>>   total   = 1#012>>>>>>   current =
0#012>>>>>> Contents:#012>>>>>>   status error =
'None' (0x00000000)#012>>>>>>   service      =
'basic-connect' (a289cc33-bcbb-8b4f-b6b0-133ec2aae6df)#012>>>>>>   cid
= 'subscriber-ready-status' (0x00000002)
2013-10-09T10:47:56.019982+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Sent message...#012<<<<<< RAW:#012<<<<<<   length =
48#012<<<<<<   data   =
03:00:00:00:30:00:00:00:12:00:00:00:01:00:00:00:00:00:00:00:A2:89:CC:33:BC:BB:8B:4F:B6:B0:13:3E:C2:AA:E6:DF:05:00:00:00:00:00:00:00:00:00:00:00
2013-10-09T10:47:56.020146+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Sent message (translated)...#012<<<<<< Header:#012<<<<<<
length      = 48#012<<<<<<   type        = command
(0x00000003)#012<<<<<<   transaction = 18#012<<<<<< Fragment
header:#012<<<<<<   total   = 1#012<<<<<<   current = 0#012<<<<<<
Contents:#012<<<<<<   service =
'basic-connect' (a289cc33-bcbb-8b4f-b6b0-133ec2aae6df)#012<<<<<<   cid
= 'pin-list' (0x00000005)#012<<<<<<   type    = 'query' (0x00000000)
2013-10-09T10:47:56.203263+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Received message...#012>>>>>> RAW:#012>>>>>>   length =
208#012>>>>>>   data   =
03:00:00:80:D0:00:00:00:12:00:00:00:01:00:00:00:00:00:00:00:A2:89:CC:33:BC:BB:8B:4F:B6:B0:13:3E:C2:AA:E6:DF:05:00:00:00:00:00:00:00:A0:00:00:00:01:00:00:00:01:00:00:00:04:00:00:00:08:00:00:00:01:00:00:00:01:00:00:00:04:00:00:00:08:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:01:00:00:00:01:00:00:00:04:00:00:00:10:00:00:00:01:00:00:00:01:00:00:00:04:00:00:00:10:00:00:00:01:00:00:00:01:00:00:00:04:00:00:00:10:00:00:00:01:00:00:00:01:00:00:00:04:00:00:00:10:00:00:00:01:00:00:00:01:00:00:00:04:00:00:00:10:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00
2013-10-09T10:47:56.209923+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Received message (translated)...#012>>>>>>
Header:#012>>>>>>   length      = 208#012>>>>>>   type        =
command-done (0x80000003)#012>>>>>>   transaction = 18#012>>>>>>
Fragment header:#012>>>>>>   total   = 1#012>>>>>>   current =
0#012>>>>>> Contents:#012>>>>>>   status error =
'None' (0x00000000)#012>>>>>>   service      =
'basic-connect' (a289cc33-bcbb-8b4f-b6b0-133ec2aae6df)#012>>>>>>   cid
= 'pin-list' (0x00000005)
2013-10-09T10:47:56.210238+02:00 linux-3m4i ModemManager[566]: <debug>
USSD support check failed: 'No AT port available to run command'
2013-10-09T10:47:56.210451+02:00 linux-3m4i ModemManager[566]: <debug>
Couldn't initialize interface: 'USSD not supported'
2013-10-09T10:47:56.210665+02:00 linux-3m4i ModemManager[566]: <debug>
loading MEID...
2013-10-09T10:47:56.210891+02:00 linux-3m4i ModemManager[566]: <warn>
couldn't load MEID: 'No AT port available to run command'
2013-10-09T10:47:56.211103+02:00 linux-3m4i ModemManager[566]: <debug>
loading ESN...
2013-10-09T10:47:56.211279+02:00 linux-3m4i ModemManager[566]: <warn>
couldn't load ESN: 'No AT port available to run command'
2013-10-09T10:47:56.211455+02:00 linux-3m4i ModemManager[566]: <debug>
Messaging capabilities supported
2013-10-09T10:47:56.211648+02:00 linux-3m4i ModemManager[566]: <debug>
Supported storages loaded:
2013-10-09T10:47:56.211822+02:00 linux-3m4i ModemManager[566]: <debug>
mem1 (list/read/delete) storages: 'mt'
2013-10-09T10:47:56.211996+02:00 linux-3m4i ModemManager[566]: <debug>
mem2 (write/send) storages:       'mt'
2013-10-09T10:47:56.212164+02:00 linux-3m4i ModemManager[566]: <debug>
mem3 (reception) storages:        'mt'
2013-10-09T10:47:56.212334+02:00 linux-3m4i ModemManager[566]: <debug>
Couldn't initialize interface: 'Time not supported'
2013-10-09T10:47:56.212504+02:00 linux-3m4i ModemManager[566]: <debug>
Couldn't initialize interface: 'Firmware not supported'
2013-10-09T10:47:56.212689+02:00 linux-3m4i ModemManager[566]: <info>
Modem /org/freedesktop/ModemManager1/Modem/0: state changed
(initializing -> disabled)
2013-10-09T10:47:57.739388+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Received message...#012>>>>>> RAW:#012>>>>>>   length =
96#012>>>>>>   data   =
07:00:00:80:60:00:00:00:00:00:00:00:01:00:00:00:00:00:00:00:53:3F:BE:EB:14:FE:44:67:9F:90:33:A2:23:E5:6C:3F:01:00:00:00:34:00:00:00:01:00:00:00:00:00:00:00:13:01:00:00:00:00:00:00:18:00:00:00:1A:00:00:00:2B:00:34:00:39:00:31:00:37:00:36:00:30:00:30:00:30:00:30:00:34:00:34:00:33:00:00:00
2013-10-09T10:47:57.740182+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Received message (translated)...#012>>>>>>
Header:#012>>>>>>   length      = 96#012>>>>>>   type        =
indicate-status (0x80000007)#012>>>>>>   transaction = 0#012>>>>>>
Fragment header:#012>>>>>>   total   = 1#012>>>>>>   current =
0#012>>>>>> Contents:#012>>>>>>   service =
'sms' (533fbeeb-14fe-4467-9f90-33a223e56c3f)#012>>>>>>   cid     =
'configuration' (0x00000001)
2013-10-09T10:47:59.659410+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Received message...#012>>>>>> RAW:#012>>>>>>   length =
144#012>>>>>>   data   =
07:00:00:80:90:00:00:00:00:00:00:00:01:00:00:00:00:00:00:00:A2:89:CC:33:BC:BB:8B:4F:B6:B0:13:3E:C2:AA:E6:DF:02:00:00:00:64:00:00:00:01:00:00:00:1C:00:00:00:1E:00:00:00:3C:00:00:00:26:00:00:00:00:00:00:00:00:00:00:00:32:00:36:00:32:00:30:00:37:00:33:00:39:00:34:00:37:00:36:00:32:00:34:00:36:00:31:00:34:00:00:00:38:00:39:00:34:00:39:00:32:00:32:00:36:00:30:00:37:00:30:00:36:00:39:00:32:00:31:00:34:00:35:00:39:00:34:00:30:00:00:00
2013-10-09T10:47:59.660803+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Received message (translated)...#012>>>>>>
Header:#012>>>>>>   length      = 144#012>>>>>>   type        =
indicate-status (0x80000007)#012>>>>>>   transaction = 0#012>>>>>>
Fragment header:#012>>>>>>   total   = 1#012>>>>>>   current =
0#012>>>>>> Contents:#012>>>>>>   service =
'basic-connect' (a289cc33-bcbb-8b4f-b6b0-133ec2aae6df)#012>>>>>>   cid
= 'subscriber-ready-status' (0x00000002)
2013-10-09T10:48:02.923277+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Received message...#012>>>>>> RAW:#012>>>>>>   length =
64#012>>>>>>   data   =
07:00:00:80:40:00:00:00:00:00:00:00:01:00:00:00:00:00:00:00:4B:F3:84:76:1E:6A:41:DB:B1:D8:BE:D2:89:C2:5B:DB:01:00:00:00:14:00:00:00:01:00:00:00:FA:00:00:00:23:00:00:00:50:00:00:00:10:00:00:00
2013-10-09T10:48:02.924258+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Received message (translated)...#012>>>>>>
Header:#012>>>>>>   length      = 64#012>>>>>>   type        =
indicate-status (0x80000007)#012>>>>>>   transaction = 0#012>>>>>>
Fragment header:#012>>>>>>   total   = 1#012>>>>>>   current =
0#012>>>>>> Contents:#012>>>>>>   service =
'phonebook' (4bf38476-1e6a-41db-b1d8-bed289c25bdb)#012>>>>>>   cid     =
'configuration' (0x00000001)
2013-10-09T10:49:49.862932+02:00 linux-3m4i ModemManager[566]: <info>
Simple connect started...
2013-10-09T10:49:49.863198+02:00 linux-3m4i ModemManager[566]: <debug>
PIN: unspecified
2013-10-09T10:49:49.863414+02:00 linux-3m4i ModemManager[566]: <debug>
Operator ID: unspecified
2013-10-09T10:49:49.863622+02:00 linux-3m4i ModemManager[566]: <debug>
Allowed roaming: yes
2013-10-09T10:49:49.863775+02:00 linux-3m4i ModemManager[566]: <debug>
APN: internet
2013-10-09T10:49:49.863936+02:00 linux-3m4i ModemManager[566]: <debug>
IP family: unspecified
2013-10-09T10:49:49.864062+02:00 linux-3m4i ModemManager[566]: <debug>
Allowed authentication: unspecified
2013-10-09T10:49:49.864178+02:00 linux-3m4i ModemManager[566]: <debug>
User: unspecified
2013-10-09T10:49:49.864294+02:00 linux-3m4i ModemManager[566]: <debug>
Password: unspecified
2013-10-09T10:49:49.864410+02:00 linux-3m4i ModemManager[566]: <debug>
Number: *99#
2013-10-09T10:49:49.864525+02:00 linux-3m4i ModemManager[566]: <info>
Simple connect state (3/8): Enable
2013-10-09T10:49:49.865117+02:00 linux-3m4i ModemManager[566]: <debug>
Couldn't start parent enabling: Couldn't open ports during modem
enabling: Couldn't get primary port
2013-10-09T10:49:49.865308+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Sent message...#012<<<<<< RAW:#012<<<<<<   length =
48#012<<<<<<   data   =
03:00:00:00:30:00:00:00:13:00:00:00:01:00:00:00:00:00:00:00:A2:89:CC:33:BC:BB:8B:4F:B6:B0:13:3E:C2:AA:E6:DF:03:00:00:00:00:00:00:00:00:00:00:00
2013-10-09T10:49:49.865435+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Sent message (translated)...#012<<<<<< Header:#012<<<<<<
length      = 48#012<<<<<<   type        = command
(0x00000003)#012<<<<<<   transaction = 19#012<<<<<< Fragment
header:#012<<<<<<   total   = 1#012<<<<<<   current = 0#012<<<<<<
Contents:#012<<<<<<   service =
'basic-connect' (a289cc33-bcbb-8b4f-b6b0-133ec2aae6df)#012<<<<<<   cid
= 'radio-state' (0x00000003)#012<<<<<<   type    = 'query' (0x00000000)
2013-10-09T10:49:49.930237+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Received message...#012>>>>>> RAW:#012>>>>>>   length =
56#012>>>>>>   data   =
03:00:00:80:38:00:00:00:13:00:00:00:01:00:00:00:00:00:00:00:A2:89:CC:33:BC:BB:8B:4F:B6:B0:13:3E:C2:AA:E6:DF:03:00:00:00:00:00:00:00:08:00:00:00:01:00:00:00:00:00:00:00
2013-10-09T10:49:49.930545+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Received message (translated)...#012>>>>>>
Header:#012>>>>>>   length      = 56#012>>>>>>   type        =
command-done (0x80000003)#012>>>>>>   transaction = 19#012>>>>>>
Fragment header:#012>>>>>>   total   = 1#012>>>>>>   current =
0#012>>>>>> Contents:#012>>>>>>   status error =
'None' (0x00000000)#012>>>>>>   service      =
'basic-connect' (a289cc33-bcbb-8b4f-b6b0-133ec2aae6df)#012>>>>>>   cid
= 'radio-state' (0x00000003)
2013-10-09T10:49:49.930718+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Sent message...#012<<<<<< RAW:#012<<<<<<   length =
52#012<<<<<<   data   =
03:00:00:00:34:00:00:00:14:00:00:00:01:00:00:00:00:00:00:00:A2:89:CC:33:BC:BB:8B:4F:B6:B0:13:3E:C2:AA:E6:DF:03:00:00:00:01:00:00:00:04:00:00:00:01:00:00:00
2013-10-09T10:49:49.930887+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Sent message (translated)...#012<<<<<< Header:#012<<<<<<
length      = 52#012<<<<<<   type        = command
(0x00000003)#012<<<<<<   transaction = 20#012<<<<<< Fragment
header:#012<<<<<<   total   = 1#012<<<<<<   current = 0#012<<<<<<
Contents:#012<<<<<<   service =
'basic-connect' (a289cc33-bcbb-8b4f-b6b0-133ec2aae6df)#012<<<<<<   cid
= 'radio-state' (0x00000003)#012<<<<<<   type    = 'set' (0x00000001)
2013-10-09T10:49:49.962281+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Received message...#012>>>>>> RAW:#012>>>>>>   length =
56#012>>>>>>   data   =
03:00:00:80:38:00:00:00:14:00:00:00:01:00:00:00:00:00:00:00:A2:89:CC:33:BC:BB:8B:4F:B6:B0:13:3E:C2:AA:E6:DF:03:00:00:00:02:00:00:00:08:00:00:00:01:00:00:00:00:00:00:00
2013-10-09T10:49:49.963360+02:00 linux-3m4i ModemManager[566]:
[/dev/cdc-wdm0] Received message (translated)...#012>>>>>>
Header:#012>>>>>>   length      = 56#012>>>>>>   type        =
command-done (0x80000003)#012>>>>>>   transaction = 20#012>>>>>>
Fragment header:#012>>>>>>   total   = 1#012>>>>>>   current =
0#012>>>>>> Contents:#012>>>>>>   status error =
'Failure' (0x00000002)#012>>>>>>   service      =
'basic-connect' (a289cc33-bcbb-8b4f-b6b0-133ec2aae6df)#012>>>>>>   cid
= 'radio-state' (0x00000003)
2013-10-09T10:49:49.963974+02:00 linux-3m4i ModemManager[566]: <info>
Modem /org/freedesktop/ModemManager1/Modem/0: state changed (enabling ->
disabled)
