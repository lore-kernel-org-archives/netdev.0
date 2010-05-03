From: Chuck Lever <chuck.lever@oracle.com>
Subject: TCP over lo
Date: Mon, 03 May 2010 16:00:48 -0400
Message-ID: <4BDF2B70.2040301@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:49072 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756381Ab0ECUA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 16:00:59 -0400
Received: from rcsinet13.oracle.com (rcsinet13.oracle.com [148.87.113.125])
	by rcsinet10.oracle.com (Switch-3.4.2/Switch-3.4.1) with ESMTP id o43K0uo7000640
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 3 May 2010 20:00:57 GMT
Received: from acsmt354.oracle.com (acsmt354.oracle.com [141.146.40.154])
	by rcsinet13.oracle.com (Switch-3.4.2/Switch-3.4.1) with ESMTP id o430kF8o005255
	for <netdev@vger.kernel.org>; Mon, 3 May 2010 20:00:55 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've got a bug report about attempting to mount a remote NFSv4 server 
while the client's lo interface is down.

Apparently a TCP connection attempt over lo when it is DOWN results in 
ETIMEDOUT.  If I attempt a TCP connect on eth0 when it is DOWN I get 
ENETUNREACH.

Is this behavior difference by design?  Is there some other information 
I'm missing?  Just wondering how to go about addressing the issue.

Thanks in advance for advice.

-- 
chuck[dot]lever[at]oracle[dot]com
