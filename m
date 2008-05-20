From: "Amit Shah" <shahamit@gmail.com>
Subject: Re: [Bugme-new] [Bug 10748] New: dhclient fails to run; capabilities error
Date: Tue, 20 May 2008 19:37:03 +0530
Message-ID: <877aabc40805200707uf2bd4d8k5d82ee7c9beeb7a5@mail.gmail.com>
References: <bug-10748-10286@http.bugzilla.kernel.org/>
	 <20080519112835.67ff4133.akpm@linux-foundation.org>
	 <20080520134919.GA8079@sergelap.wowway.com>
	 <1211290714.7486.105.camel@moss-spartans.epoch.ncsc.mil>
	 <1211291902.7486.121.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	"Andrew Morgan" <morgan@kernel.org>
To: "Stephen Smalley" <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.235]:31534 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753283AbYETOHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 10:07:06 -0400
Received: by rv-out-0506.google.com with SMTP id l9so2033380rvb.1
        for <netdev@vger.kernel.org>; Tue, 20 May 2008 07:07:04 -0700 (PDT)
In-Reply-To: <1211291902.7486.121.camel@moss-spartans.epoch.ncsc.mil>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 20, 2008 at 7:28 PM, Stephen Smalley <sds@tycho.nsa.gov> wrote:
>
> On Tue, 2008-05-20 at 09:38 -0400, Stephen Smalley wrote:
>> Which means that he is using the dummy security module.
>> And it appears that a prior commit moved KEEPCAPS handling from
>> core prctl() to cap_task_prctl(), but didn't replicate it in
>> the dummy_task_prctl().
>>
>> The dummy module really needs to die.
>
> Question for the bug reporter:  did you really mean to build a kernel
> without capabilities support?  Surprise!  They don't really work when
> disabled.

No; I was just trying out some random configs. This config worked till
.25 properly though.

-- 
Amit Shah
http://www.amitshah.net/
