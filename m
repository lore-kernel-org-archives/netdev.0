From: Li RongQing <roy.qing.li@gmail.com>
Subject: Re: [PATCH net-next v2] ipconfig: send Client-identifier in DHCP requests
Date: Fri, 16 Oct 2015 07:54:43 +0800
Message-ID: <CAJFZqHxAN+p+MKvMDdhYwPXJR5+wd6Ci3RDggrE-2V06h8nAiQ@mail.gmail.com>
References: <1444899276-21228-1-git-send-email-roy.qing.li@gmail.com>
	<CAGVrzcaDXgpao7SjhRg3UE67gMSzD70vjQV2gXkF5=OZsxykfw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:35108 "EHLO
	mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371AbbJOXyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 19:54:44 -0400
Received: by qkap81 with SMTP id p81so47445819qka.2
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 16:54:43 -0700 (PDT)
In-Reply-To: <CAGVrzcaDXgpao7SjhRg3UE67gMSzD70vjQV2gXkF5=OZsxykfw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 15, 2015 at 10:56 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> Did not you mean strlen(dhcp_client_identifer) + 1 instead?


no;
dhcp_client_identifer[0] is client identifier type, and it maybe 0;
dhcp_client_identifer+1 is the start address of client identifier value;

-Roy
