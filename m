From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Long delays creating a netns after deleting one (possibly RCU
 related)
Date: Fri, 18 Nov 2016 16:41:20 -0800
Message-ID: <1479516080.8455.306.camel@edumazet-glaptop3.roam.corp.google.com>
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
         <1479163571.8455.83.camel@edumazet-glaptop3.roam.corp.google.com>
         <1479164967.8455.87.camel@edumazet-glaptop3.roam.corp.google.com>
         <884D43D4-024E-4485-94E6-1E8DFF972483@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Rolf Neugebauer <rolf.neugebauer@docker.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Justin Cormack <justin.cormack@docker.com>,
        Ian Campbell <ian.campbell@docker.com>,
        Eric Dumazet <edumazet@google.com>
To: Jarno Rajahalme <jarno.rajahalme@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <884D43D4-024E-4485-94E6-1E8DFF972483@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-11-18 at 16:38 -0800, Jarno Rajahalme wrote:

> This fixes the problem for me, so for whatever it’s worth:
> 
> Tested-by: Jarno Rajahalme <jarno@ovn.org>
> 

Thanks for testing !

https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=e88a2766143a27bfe6704b4493b214de4094cf29
