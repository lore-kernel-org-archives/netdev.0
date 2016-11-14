From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Long delays creating a netns after deleting one (possibly RCU
 related)
Date: Mon, 14 Nov 2016 14:46:11 -0800
Message-ID: <1479163571.8455.83.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CA+pO-2f+7QfsLiFwvGcNqTrQ0t8B5+w0vZHFrshWsSWgDE6iUg@mail.gmail.com>
         <CAM_iQpUNRyv3wHi3cJpcH6avo+D7Gxwqp+iybUxYc7PCo3WUPw@mail.gmail.com>
         <20161110212404.GB4127@linux.vnet.ibm.com>
         <CA+pO-2ddoJYvhVoV3Bo+-3K7V63eY9sbKzKwYrut65GZXs6_1g@mail.gmail.com>
         <20161112002347.GL4127@linux.vnet.ibm.com>
         <CAM_iQpUDnPfVayQv7Q+ZtC_2_ZbX9MRX=514gFpF3E6XY+GtSA@mail.gmail.com>
         <CAM_iQpUq14GsvGyz2xA1PkDq5YO743T68Zh2zm=NJZQ9S2Ahqg@mail.gmail.com>
         <20161114162417.GJ4127@linux.vnet.ibm.com>
         <CAM_iQpXL+JaVG86+h2ucYs4Dm0zJKHq+4Nm+gk75wESGOzTmJQ@mail.gmail.com>
         <20161114181425.GN4127@linux.vnet.ibm.com> <87y40lhfrt.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Rolf Neugebauer <rolf.neugebauer@docker.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Justin Cormack <justin.cormack@docker.com>,
        Ian Campbell <ian.campbell@docker.com>,
        Eric Dumazet <edumazet@google.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87y40lhfrt.fsf@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-11-14 at 16:12 -0600, Eric W. Biederman wrote:

> synchronize_rcu_expidited is not enough if you have multiple network
> devices in play.
> 
> Looking at the code it comes down to this commit, and it appears there
> is a promise add rcu grace period combining by Eric Dumazet.
> 
> Eric since people are hitting noticable stalls because of the rcu grace
> period taking a long time do you think you could look at this code path
> a bit more?
> 
> commit 93d05d4a320cb16712bb3d57a9658f395d8cecb9
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Wed Nov 18 06:31:03 2015 -0800

Absolutely, I will take a loop asap.

Thanks Eric.
