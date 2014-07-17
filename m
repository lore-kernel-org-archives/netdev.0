From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH v8] net: set name assign type for names assigned using a
 static string
Date: Thu, 17 Jul 2014 09:26:50 +0200
Message-ID: <20140717072649.GA3620@redhat.com>
References: <1405550594-11786-1-git-send-email-teg@jklm.no>
 <20140716.235609.2266614502105510844.davem@davemloft.net>
 <CAG-2HqU=+DU3G-kxmf6rLGdKdN2ybUPiwsRN-HBYyu-ViZ8x0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Tom Gundersen <teg@jklm.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAG-2HqU=+DU3G-kxmf6rLGdKdN2ybUPiwsRN-HBYyu-ViZ8x0A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 17, 2014 at 09:17:07AM +0200, Tom Gundersen wrote:
>On Thu, Jul 17, 2014 at 8:56 AM, David Miller <davem@davemloft.net> wrote:
>> Tom, even if the patches are sort of independent, they logically
>> belong together.
>>
>> So please number them, and provide an appropriate "[PATCH 0/N] ..."
>> cover letter.
>>
>> Please resubmit these patches with that done properly, thank you.
>
>Ok. Will do.

Also, it would be really nice if you could send patches as
Doc/net/netdev-FAQ.txt suggests, as lots of us have scripts that parse the
subject to find out which tree to apply/test the patches.

It's also easier than using git notes edit/git send-email --notes :).

Q: How do I indicate which tree (net vs. net-next) my patch should be in?

A: Firstly, think whether you have a bug fix or new "next-like" content.
   Then once decided, assuming that you use git, use the prefix flag, i.e.

        git format-patch --subject-prefix='PATCH net-next' start..finish

   Use "net" instead of "net-next" (always lower case) in the above for
   bug-fix net content.  If you don't use git, then note the only magic in
   the above is just the subject text of the outgoing e-mail, and you can
   manually change it yourself with whatever MUA you are comfortable with.

>
>Thanks.
>
>Tom
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
