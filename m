From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: [PATCH] qdisc oops fix
Date: Wed, 16 Apr 2003 18:52:56 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E9D8A68.5050207@colorfullife.com>
References: <20030415084706.O1131@shell.cyberus.ca> <Pine.LNX.4.53.0304160838001.25861@hosting.rdsbv.ro> <20030416072952.E4013@shell.cyberus.ca> <3E9D755A.8060601@colorfullife.com> <20030416160606.GA32575@louise.pinerecords.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, Catalin BOIE <util@deuroconsult.ro>,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: Tomas Szepe <szepe@pinerecords.com>
In-Reply-To: <20030416160606.GA32575@louise.pinerecords.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Tomas Szepe wrote:

>The original backtrace as provided by Martin Volf does not contain
>any weird addresses such as 0xd081ecc7 above:
>
>http://marc.theaimsgroup.com/?l=linux-kernel&m=105013596721774&w=2
>  
>
Thanks.
The bug was caused by sch_tree_lock() in htb_change_class().
2.4.21-pre7 contains a fix.

--
    Manfred
