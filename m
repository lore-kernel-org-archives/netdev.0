From: Krishna Kumar <kumarkr@us.ibm.com>
Subject: Re: rudimentary ISR question
Date: Mon, 12 Apr 2004 16:23:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF0DAE5AB0.7BE32C3B-ON88256E74.007FB9B2@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/related;
	Boundary="0__=07BBE4E7DFEC3F228f9e8a93df938690918c07BBE4E7DFEC3F22"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Steve Modica <modica@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4E7DFEC3F228f9e8a93df938690918c07BBE4E7DFEC3F22
Content-type: multipart/alternative;
	Boundary="1__=07BBE4E7DFEC3F228f9e8a93df938690918c07BBE4E7DFEC3F22"

--1__=07BBE4E7DFEC3F228f9e8a93df938690918c07BBE4E7DFEC3F22
Content-type: text/plain; charset=US-ASCII





I think it is because the interrupt routine can be called as
dev->poll_controller()
and race with real interrupts.

- KK



|---------+---------------------------->
|         |           Steve Modica     |
|         |           <modica@sgi.com> |
|         |           Sent by:         |
|         |           netdev-bounce@oss|
|         |           .sgi.com         |
|         |                            |
|         |                            |
|         |           04/12/2004 03:16 |
|         |           PM               |
|         |                            |
|---------+---------------------------->
  >-------------------------------------------------------------------------------------------------------------------------|
  |                                                                                                                         |
  |       To:       netdev@oss.sgi.com                                                                                      |
  |       cc:                                                                                                               |
  |       Subject:  rudimentary ISR question                                                                                |
  |                                                                                                                         |
  >-------------------------------------------------------------------------------------------------------------------------|




Hi All,

I'm looking at the tg3.c driver in the 2.4.21 kernel and in the
_interrupt routing, the driver is calling spin_lock_irqsave.

Since it's guaranteed that the tg3 interrupt handler will be disabled
for the duration of the interrupt handler, why can't the driver simply
call spin_lock?

Steve



--1__=07BBE4E7DFEC3F228f9e8a93df938690918c07BBE4E7DFEC3F22
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>I think it is because the interrupt routine can be called as dev-&gt;poll_controller()<br>
and race with real interrupts.<br>
<br>
- KK<br>
<br>
<img src="cid:10__=07BBE4E7DFEC3F228f9e8a93df938@us.ibm.com" width="16" height="16" alt="Inactive hide details for Steve Modica &lt;modica@sgi.com&gt;">Steve Modica &lt;modica@sgi.com&gt;<br>
<br>
<br>

<table V5DOTBL=true width="100%" border="0" cellspacing="0" cellpadding="0">
<tr valign="top"><td width="1%"><img src="cid:20__=07BBE4E7DFEC3F228f9e8a93df938@us.ibm.com" border="0" height="1" width="72" alt=""><br>
</td><td style="background-image:url(cid:30__=07BBE4E7DFEC3F228f9e8a93df938@us.ibm.com); background-repeat: no-repeat; " width="1%"><img src="cid:20__=07BBE4E7DFEC3F228f9e8a93df938@us.ibm.com" border="0" height="1" width="225" alt=""><br>

<ul>
<ul>
<ul>
<ul><b><font size="2">Steve Modica &lt;modica@sgi.com&gt;</font></b><br>
<font size="2">Sent by: netdev-bounce@oss.sgi.com</font>
<p><font size="2">04/12/2004 03:16 PM</font></ul>
</ul>
</ul>
</ul>
</td><td width="100%"><img src="cid:20__=07BBE4E7DFEC3F228f9e8a93df938@us.ibm.com" border="0" height="1" width="1" alt=""><br>
<font size="1" face="Arial">	</font><br>
<font size="2">	To:	</font><font size="2">netdev@oss.sgi.com</font><br>
<font size="2">	cc:	</font><br>
<font size="2">	Subject:	</font><font size="2">rudimentary ISR question</font></td></tr>
</table>
<br>
<br>
<font face="Courier New">Hi All,<br>
<br>
I'm looking at the tg3.c driver in the 2.4.21 kernel and in the <br>
_interrupt routing, the driver is calling spin_lock_irqsave.<br>
<br>
Since it's guaranteed that the tg3 interrupt handler will be disabled <br>
for the duration of the interrupt handler, why can't the driver simply <br>
call spin_lock?<br>
<br>
Steve<br>
<br>
</font>

</body></html>

--1__=07BBE4E7DFEC3F228f9e8a93df938690918c07BBE4E7DFEC3F22--


--0__=07BBE4E7DFEC3F228f9e8a93df938690918c07BBE4E7DFEC3F22
Content-type: image/gif;
	name="graycol.gif"
Content-Disposition: inline; filename="graycol.gif"
Content-ID: <10__=07BBE4E7DFEC3F228f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAAQAKECAMzMzAAAAP///wAAACH5BAEAAAIALAAAAAAQABAAAAIXlI+py+0PopwxUbpu
ZRfKZ2zgSJbmSRYAIf4fT3B0aW1pemVkIGJ5IFVsZWFkIFNtYXJ0U2F2ZXIhAAA7

--0__=07BBE4E7DFEC3F228f9e8a93df938690918c07BBE4E7DFEC3F22
Content-type: image/gif;
	name="ecblank.gif"
Content-Disposition: inline; filename="ecblank.gif"
Content-ID: <20__=07BBE4E7DFEC3F228f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhEAABAIAAAAAAAP///yH5BAEAAAEALAAAAAAQAAEAAAIEjI8ZBQA7

--0__=07BBE4E7DFEC3F228f9e8a93df938690918c07BBE4E7DFEC3F22
Content-type: image/gif;
	name="pic29317.gif"
Content-Disposition: inline; filename="pic29317.gif"
Content-ID: <30__=07BBE4E7DFEC3F228f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

R0lGODlhWABDALP/AAAAAK04Qf79/o+Gm7WuwlNObwoJFCsoSMDAwGFsmIuezf///wAAAAAAAAAA
AAAAACH5BAEAAAgALAAAAABYAEMAQAT/EMlJq704682770RiFMRinqggEUNSHIchG0BCfHhOjAuh
EDeUqTASLCbBhQrhG7xis2j0lssNDopE4jfIJhDaggI8YB1sZeZgLVA9YVCpnGagVjV171aRVrYR
RghXcAGFhoUETwYxcXNyADJ3GlcSKGAwLwllVC1vjIUHBWsFilKQdI8GA5IcpApeJQt8L09lmgkH
LZikoU5wjqcyAMMFrJIDPAKvCFletKSev1HBw8KrxtjZ2tvc3d5VyKtCKW3jfz4uMKmq3xu4N0nK
BVoJQmx2LGVOmrqNjjJf2hHAQo/eDwJGTKhQMcgQEEAnEjFS98+RnW3smGkZU6ncCWav/4wYOnAI
TihRL/4FEwbp28BXMMcoscQCVxlepL4IGDSCyJyVQOu0o7CjmLN50OZlqWmyFy5/6yBBuji0AxFR
M00oQAqNIstqI6qKHUsWRAEAvagsmfUEAImyxgbmUpJk3IklNUtJOUAVLoUr1+wqDGTE4zk+T6FG
uQb3SizBCwatiiUgCBN8vrz+zFjVyQ8FWkOlg4NQiZMB5QS8QO3mpOaKnL0Z2EKvNMSILEThKhCg
zMKPVxYJh23qm9KNW7pArPynMqZDiErsTMqI+LRi3QAgkFUbXpuFKhSYZALd0O5RKa2z9EYKBbpb
qxIKsjUPRgD7I2XYV6wyrOw92ykExP8NW4URhknC5dKGE4v4NENQj2jXjmfNgOZDaXb5glRmXQ33
YEWQYNcZFnrYcIQLNzyTFDQNkXIff0ExVlY4srziQk43inZgL4rwxxINMvpFFAz1KOODHiu+4aEw
NEjFl5B3JIKWKF3k6I9bfUGp5ZZcdunll5IA4cuHvQQJ5gcsoCWOOUwgltIwAKRxJgbIkJAQZEq0
2YliZnpZZ4BH3CnYOXldOUOfQoYDqF1LFHbXCrO8xmRsfoXDXJ6ChjCAH3QlhJcT6VWE6FCkfCco
CgrMFsROrIEX3o2whVjWDjoJccN3LdggSGXLCdLEgHr1lyU3O3QxhgohNKXJCWv8JQr/PDdaqd6w
2rj1inLiGeiCJoDspAoQlYE6QWLSECehcWIYxIQES6zhbn1iImTHEQyqJ4eIxJJoUBc+3CbBuwZE
V5cJPPkIjFDdeEabQbd6WgICTxiiz0f5dBKquXF6k4senwEhYGnKEFJeGrxUZy8dB8gmAXI/sPvH
ESfCwVt5hTgYiqQqtdRNHQIU1PJ33ZqmzgE90OwLaoJcnMop1WiMmgkPHQRIrwgFuNV90A3doNKT
mrKIN07AnGcI9BQjhCBN4RfA1qIZnMqorJCogKfGQnxSCDilTVIA0yl5ciTovgLuBDKFUDE9aQcw
9SA+rjSNf9/M1gxrj6VwDTS0IUSElMzBfsj0NFXR2kwsV1A5IF1grLgLL/r1R40BZEnuBWgmQEyb
jqRwSAt6bqMCOFkvKFN2GPPkUzIm/SCF8z8pVzpbjVnMsy0vOr1hw3SaSRUhpY09v0z0J1FnwzPl
fmh+xl4WtR0zGu24I4KbMQm3lnVu2oNWxI9W/lcyzA+mCKF4DBikxb/+UWtOGRiFP8qEwAayIgIA
Ow==

--0__=07BBE4E7DFEC3F228f9e8a93df938690918c07BBE4E7DFEC3F22--
