From: dlezcano@fr.ibm.com
Subject: [patch 0/1][RFC] add a private field to the sock structure
Date: Wed, 29 Aug 2007 18:41:14 +0200
Message-ID: <20070829164114.868188182@f002726.toulouse-stg.fr.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([195.212.29.140]:62670 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753313AbXH2Qx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 12:53:29 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate7.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l7TGrSJO576736
	for <netdev@vger.kernel.org>; Wed, 29 Aug 2007 16:53:28 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7TGrS4V2691162
	for <netdev@vger.kernel.org>; Wed, 29 Aug 2007 17:53:28 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7TGrFSb010013
	for <netdev@vger.kernel.org>; Wed, 29 Aug 2007 17:53:15 +0100
Received: from f002726.toulouse-stg.fr.ibm.com (dyn-9-101-17-26.toulouse-stg.fr.ibm.com [9.101.17.26])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id l7TGrEca009850
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 29 Aug 2007 17:53:15 +0100
Received: from f002726.toulouse-stg.fr.ibm.com (localhost.localdomain [127.0.0.1])
	by f002726.toulouse-stg.fr.ibm.com (8.14.1/8.14.1) with ESMTP id l7TGlEI4029219
	for <netdev@vger.kernel.org>; Wed, 29 Aug 2007 18:47:14 +0200
Received: (from dlezcano@localhost)
	by f002726.toulouse-stg.fr.ibm.com (8.14.1/8.14.1/Submit) id l7TGlD9Z029218
	for netdev@vger.kernel.org; Wed, 29 Aug 2007 18:47:13 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When a socket is created it is sometime useful to store a specific information
for this socket.
 
This information can be for examples: 
	* a creation time
	* a pid
	* a uid/gid
	* a container identifier
	* a pointer to a more specific structure
	* ...

The following patch is a proposition to add a private anonymous pointer
field to the common part of the sock structure.

-- 
