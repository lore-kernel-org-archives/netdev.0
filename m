From: John Haxby <john.haxby@oracle.com>
Subject: inet_hash_connect: source port allocation
Date: Mon, 29 Nov 2010 17:04:02 +0000
Message-ID: <4CF3DD02.90906@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:61286 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752107Ab0K2RKw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 12:10:52 -0500
Received: from acsinet15.oracle.com (acsinet15.oracle.com [141.146.126.227])
	by rcsinet10.oracle.com (Switch-3.4.2/Switch-3.4.2) with ESMTP id oATHAonY023083
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 17:10:51 GMT
Received: from acsmt355.oracle.com (acsmt355.oracle.com [141.146.40.155])
	by acsinet15.oracle.com (Switch-3.4.2/Switch-3.4.1) with ESMTP id oAT24mTE031721
	for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 17:10:48 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Please forgive me if this is a stupid question, but is there any 
particular reason why the source port allocation in 
__inet_hash_connect() shouldn't use the same random allocation that 
inet_csk_get_port() uses?  The latter, of course, is used when bind() 
doesn't specify a source port but the implicit "bind" for a connect() 
gets its port allocated by __inet_hash_connect().

jch
