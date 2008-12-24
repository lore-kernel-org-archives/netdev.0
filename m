From: "J. K. Cliburn" <jcliburn@gmail.com>
Subject: Re: [Bugme-new] [Bug 12282] New: Network data corruption on eee 1000
Date: Wed, 24 Dec 2008 07:32:36 -0600
Message-ID: <3400f2f60812240532s23c8f218q51e4717f4231b3bc@mail.gmail.com>
References: <bug-12282-10286@http.bugzilla.kernel.org/>
	 <20081223232035.5a5caea9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	"Jie Yang" <jie.yang@atheros.com>
To: walken@zoy.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:50524 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392AbYLXNcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 08:32:39 -0500
Received: by ewy10 with SMTP id 10so3244823ewy.13
        for <netdev@vger.kernel.org>; Wed, 24 Dec 2008 05:32:37 -0800 (PST)
In-Reply-To: <20081223232035.5a5caea9.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 24, 2008 at 1:20 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
>
> On Tue, 23 Dec 2008 21:24:45 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:
>
>> http://bugzilla.kernel.org/show_bug.cgi?id=12282
>>
>>            Summary: Network data corruption on eee 1000

Do things improve if you turn off TSO in the atl1e driver?

ethtool -K eth0 tso off
