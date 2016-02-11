From: Brian Russell <brian.russell@brocade.com>
Subject: Re: [PATCH net-next 1/2] nsh: encapsulation module
Date: Thu, 11 Feb 2016 16:39:02 +0000
Message-ID: <56BCB926.6020604@brocade.com>
References: <1455186914-8952-1-git-send-email-brussell@brocade.com>
 <1455186914-8952-3-git-send-email-brussell@brocade.com>
 <56BCB429.2060600@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
To: Robert Shearman <rshearma@brocade.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:5886 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750979AbcBKQjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 11:39:17 -0500
Received: from pps.filterd (m0000700.ppops.net [127.0.0.1])
	by mx0b-000f0801.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u1BGWClS005838
	for <netdev@vger.kernel.org>; Thu, 11 Feb 2016 08:39:16 -0800
Received: from brmwp-exmb11.corp.brocade.com ([208.47.132.227])
	by mx0b-000f0801.pphosted.com with ESMTP id 20wfbacsuv-3
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 11 Feb 2016 08:39:16 -0800
In-Reply-To: <56BCB429.2060600@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 11/02/16 16:17, Robert Shearman wrote:
> On 11/02/16 11:35, Brian Russell wrote:
> ...
>> diff --git a/include/net/nsh.h b/include/net/nsh.h
>> new file mode 100644
>> index 0000000..7a5fb95
>> --- /dev/null
>> +++ b/include/net/nsh.h
>> @@ -0,0 +1,158 @@
>> +/*
>> + * Network Service Header (NSH) inserted onto encapsulated packets
>> + * or frames to realize service function paths.
>> + * NSH also provides a mechanism for metadata exchange along the
>> + * instantiated service path.
>> + *
>> + * https://tools.ietf.org/html/draft-ietf-sfc-nsh-01
>> + *
>> + * Copyright (c) 2015 by Brocade Communications Systems, Inc.
>> + * All rights reserved.
>> + */
> 
> All rights reserved isn't really compatible with the GPL :-)
> 

Oops. Will fix that up in next version.

Thanks,

Brian

> ...
>> diff --git a/net/ipv4/nsh.c b/net/ipv4/nsh.c
>> new file mode 100644
>> index 0000000..70e5ef0
>> --- /dev/null
>> +++ b/net/ipv4/nsh.c
>> @@ -0,0 +1,362 @@
>> +/*
>> + * Network Service Header (NSH) inserted onto encapsulated packets
>> + * or frames to realize service function paths.
>> + * NSH also provides a mechanism for metadata exchange along the
>> + * instantiated service path.
>> + *
>> + * https://tools.ietf.org/html/draft-ietf-sfc-nsh-01
>> + *
>> + * Copyright (c) 2015 by Brocade Communications Systems, Inc.
>> + * All rights reserved.
>> + */
> 
> Ditto.
> 
> Thanks,
> Rob
> 
