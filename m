From: Matteo Croce <mcroce@redhat.com>
Subject: Re: [PATCH net] ipv6: fix net.ipv6.conf.all interface DAD handlers
Date: Fri, 29 Sep 2017 12:47:09 +0200
Message-ID: <CAGnkfhx0v8XULWBQ2eWOPf_=wsVTmiABJ8O_FBrf7ckzP+HRZQ@mail.gmail.com>
References: <20170912154637.12996-1-mcroce@redhat.com> <20170915.141227.723470226137757556.davem@davemloft.net>
 <CAAedzxp4jdzycLXrXcdbpgnMCK0LJoaTiBV4m6=giV_T+WLkwA@mail.gmail.com> <CAAedzxrLurc=oGy64ePO30j3QQ_sL5kJCEz+RnTk3LMSn_yvyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, linux-doc@vger.kernel.org
To: Erik Kline <ek@google.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CAAedzxrLurc=oGy64ePO30j3QQ_sL5kJCEz+RnTk3LMSn_yvyQ@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 28, 2017 at 1:22 PM, Erik Kline <ek@google.com> wrote:
> Upon further reflection, doesn't the whole premise of this change
> means that it's no longer possible to selectively disable these
> features if they are set on "all"?  Or are we saying that this mode is
> only support with "default" enable + "ifname" disable?

Hi Erik, thanks for the review.
Yes the behaviour seems wrong when writing all.accept_dad respect what
the documentation says.

BTW the previous behaviour was not defined, I put them in OR because
that's what other handlers do, eg. send_redirects.
If you think that it's better to put them in AND we can change the
documentation accordingly.
What do you think?

-- 
Matteo Croce
per aspera ad upstream
