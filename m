From: Flavio Leitner <fbl@sysclose.org>
Subject: TCP keepalive question
Date: Fri, 16 Apr 2010 12:06:44 -0300
Message-ID: <20100416150644.GA2641@sysclose.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="9jxsPFA5p3P2qPhR"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:60773 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756415Ab0DPPHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 11:07:38 -0400
Received: from homiemail-a12.g.dreamhost.com (caiajhbdcbef.dreamhost.com [208.97.132.145])
	by hapkido.dreamhost.com (Postfix) with ESMTP id 1CF2C17C458
	for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 08:07:38 -0700 (PDT)
Received: from localhost (unknown [189.123.214.170])
	by homiemail-a12.g.dreamhost.com (Postfix) with ESMTPA id 1567C714083
	for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 08:06:57 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--9jxsPFA5p3P2qPhR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


Hi,


I'm reading the RFC 1122 and it says the following:
...
           Keep-alive packets MUST only be sent when no data or
           acknowledgement packets have been received for the
           connection within an interval.  
...

The receiving acknowledgement part seems to be ok and handled 
by tcp_keepalive_timer() when it does 
elapsed = tcp_time_stamp - tp->rcv_tstamp;

However, if one side just receive data and reply with ACK, the
keepalive probes is sent anyway - 2.6.32.9-70.fc12.i686.PAE.

Any reason to not reset keepalive timer when data is received?

Socket options used:
SO_KEEPALIVE, TCP_KEEPIDLE=40, TCP_KEEPCNT=6, TCP_KEEPINTVL=5

Traffic dump attached.

thanks!
-- 
Flavio

--9jxsPFA5p3P2qPhR
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="keepalive.pcap.gz"
Content-Transfer-Encoding: base64

H4sICMN8yEsCA2tlZXBhbGl2ZS5wY2FwAIXSS0gbURTG8TPJ5FFJx7TEVPGBEuuiDUrr2FYQ
CYKYKmRhpAgi0kVWhhZScCOIplCRQpelRoQI3WkjiCuXUcSdLhLNRvC5MvFRshFL0nNuco1M
x9vAkCGE3/3zcRPrKwsGkIF/8nkACb+/fNrqOzlSoBff6YGKwQlbYKAf3F+/WaEboMNm9IDH
nHAuNUgj+Ejp4fDV+aI/QX+OGpw7G8sABtm0KhusZfB6ZI9+l4xGC8k1xyW5YBb8ggxA8kEV
qaSHr9LDH7z1z1FPRh87o9FQSXa4pjZJR9lM8j7KXah26TWrNpk112qak6i7J+3QfBrDRon1
pkiOoNiZVcCHmE9P9NhMTLTripXQ7FW5+CtHojcQDH6s9wdCY4EQ6fPZUu8/S6gLZ6R3vtIs
4cYTDrF36O2zgu5wbZ/RCTEUI0dCMc3ENp1tmXijFMXGOgsX/7OpmS1QrVngkG96084X+FNN
nSTOQbloUwsTFV0RN13cvxVdJN7dlPQU6oIFMmwBVWfTDC2wlLxdQKET4ij+loW9Vtb7UNOb
4b3lM8XeN71eUu/2ku4zCXvPWW+rTu819do/895gC52wi+Ks+A5cMPGlzh1gYnyUi2s9XDwR
34EHbIFKzQLX/A7Ev/MFfrynzhyK4+LGS9b44r7G1KNi49N306SSGBM3lrHGJ/c1NvmLje3q
T9ryL8KrN3YaBQAA

--9jxsPFA5p3P2qPhR--
